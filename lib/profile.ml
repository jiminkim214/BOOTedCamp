module Profile = struct
  (** Types and Data Structures **)

  type skill_status =
    | NotStarted
    | InProgress
    | Completed

  type skill_progress = {
    skill_name : string;
    description : string;
    status : skill_status;
  }

  type category_progress = {
    category_name : string;
    skills : skill_progress list;
  }

  type t = {
    username : string;
    mutable categories : category_progress list;
  }

  (** Status conversion **)
  let status_to_string = function
    | NotStarted -> "Not Started"
    | InProgress -> "In Progress"
    | Completed -> "Completed"

  let string_to_status s =
    match String.lowercase_ascii s with
    | "not started" -> NotStarted
    | "in progress" -> InProgress
    | "completed" -> Completed
    | _ -> NotStarted

  (** Helpers **)
  let skill_count_for_status skills st =
    List.fold_left
      (fun acc skillp -> if skillp.status = st then acc + 1 else acc)
      0 skills

  let total_skills cat = List.length cat.skills
  let completed_skills cat = skill_count_for_status cat.skills Completed
  let inprogress_skills cat = skill_count_for_status cat.skills InProgress
  let notstarted_skills cat = skill_count_for_status cat.skills NotStarted

  (** Loading and Saving Profiles **)

  (* Save the profile to data/user_profiles.csv Format:
     username,category,skill_name,status *)
  let save_profile (profile : t) =
    let file = "data/user_profiles.csv" in
    (* Load existing CSV *)
    let rows = if Sys.file_exists file then Csv.load file else [] in
    (* Remove all rows for this user *)
    let filtered =
      List.filter
        (fun row ->
          match row with
          | [ u; _; _; _ ] -> u <> profile.username
          | _ -> true)
        rows
    in
    (* Add rows from the profile *)
    let new_rows =
      List.fold_left
        (fun acc cat ->
          List.fold_left
            (fun acc2 skill ->
              let line =
                [
                  profile.username;
                  cat.category_name;
                  skill.skill_name;
                  status_to_string skill.status;
                ]
              in
              line :: acc2)
            acc cat.skills)
        filtered profile.categories
    in
    Csv.save file new_rows

  (* Load an existing profile for a given username, given the tutorials. If no
     entries for the user, return None *)
  let load_profile ~username ~(tutorials : (string * Tutorial.skill list) list)
      =
    let file = "data/user_profiles.csv" in
    if not (Sys.file_exists file) then None
    else
      let rows = Csv.load file in
      (* Filter rows for this username *)
      let user_rows =
        List.filter
          (fun row ->
            match row with
            | [ u; _; _; _ ] -> u = username
            | _ -> false)
          rows
      in
      if user_rows = [] then None
      else
        (* Build categories and skills from user_rows *)
        let cat_map = Hashtbl.create 10 in
        (* tutorials gives us description, we must match them with user_rows *)
        let desc_map = Hashtbl.create 10 in
        List.iter
          (fun (cat_name, skill_list) ->
            List.iter
              (fun skl ->
                Hashtbl.add desc_map
                  (cat_name, skl.Tutorial.name)
                  skl.description)
              skill_list)
          tutorials;

        List.iter
          (fun row ->
            match row with
            | [ _; cat; skill_name; status_str ] ->
                let status = string_to_status status_str in
                let description =
                  try Hashtbl.find desc_map (cat, skill_name)
                  with Not_found -> ""
                  (* no description found, should not happen if tutorials are
                     consistent *)
                in
                let skillp = { skill_name; description; status } in
                if Hashtbl.mem cat_map cat then
                  let skills = Hashtbl.find cat_map cat in
                  Hashtbl.replace cat_map cat (skillp :: skills)
                else Hashtbl.add cat_map cat [ skillp ]
            | _ -> ())
          user_rows;

        let categories =
          Hashtbl.fold
            (fun cat_name skills acc ->
              { category_name = cat_name; skills = List.rev skills } :: acc)
            cat_map []
        in
        Some { username; categories }

  (* Initialize a profile from scratch if no profile file exists for user *)
  let init_profile ~username ~(tutorials : (string * Tutorial.skill list) list)
      =
    let categories =
      List.map
        (fun (cat_name, skill_list) ->
          let skills =
            List.map
              (fun skl ->
                {
                  skill_name = skl.Tutorial.name;
                  description = skl.description;
                  status = NotStarted;
                })
              skill_list
          in
          { category_name = cat_name; skills })
        tutorials
    in
    { username; categories }

  (* Try loading profile, if none found, init a new one *)
  let load_or_init_profile ~username ~tutorials =
    match load_profile ~username ~tutorials with
    | Some p -> p
    | None -> init_profile ~username ~tutorials

  (** Updating skill status **)

  let update_skill_status (profile : t) ~category_name ~skill_name ~new_status =
    let rec update_skill_in_list skills =
      match skills with
      | [] -> []
      | s :: rest when s.skill_name = skill_name ->
          { s with status = new_status } :: rest
      | other :: rest -> other :: update_skill_in_list rest
    in
    let rec update_cat cats =
      match cats with
      | [] -> []
      | c :: rest when c.category_name = category_name ->
          let updated_skills = update_skill_in_list c.skills in
          { c with skills = updated_skills } :: rest
      | other :: rest -> other :: update_cat rest
    in
    profile.categories <- update_cat profile.categories;
    (* Save after update *)
    save_profile profile

  (** Querying the profile **)

  let get_skill_status (profile : t) ~category_name ~skill_name =
    let cat_opt =
      List.find_opt
        (fun c -> c.category_name = category_name)
        profile.categories
    in
    match cat_opt with
    | None -> None
    | Some c -> (
        let skill_opt =
          List.find_opt (fun s -> s.skill_name = skill_name) c.skills
        in
        match skill_opt with
        | None -> None
        | Some sk -> Some sk.status)

  let total_completed (profile : t) =
    List.fold_left (fun acc c -> acc + completed_skills c) 0 profile.categories

  let total_skills_all (profile : t) =
    List.fold_left (fun acc c -> acc + total_skills c) 0 profile.categories

  (** Ranking System **)
  let get_rank_and_emoji completed_count =
    if completed_count = 0 then ("Bronze", "🥉")
    else if completed_count = 1 then ("Silver", "🥈")
    else if completed_count = 2 then ("Gold", "🥇")
    else if completed_count = 3 then ("Master", "🏆")
    else ("Champion", "👑")

  (** Rendering Functions **)

  let render_progress_bar (cat : category_progress) =
    let total = float_of_int (total_skills cat) in
    let comp = float_of_int (completed_skills cat) in
    let ratio = if total = 0. then 0. else comp /. total in
    let width = 20 in
    let filled_count = int_of_float (ratio *. float_of_int width) in
    let filled = String.make filled_count '#' in
    let unfilled = String.make (width - filled_count) '-' in
    Printf.sprintf "[%s%s] %d/%d Completed" filled unfilled (int_of_float comp)
      (int_of_float total)

  let render_category_block (c : category_progress) =
    let cat_header = Printf.sprintf "Category: %s" c.category_name in
    let bar = render_progress_bar c in
    let skills_str =
      List.map
        (fun s ->
          let st = status_to_string s.status in
          Printf.sprintf "  - %s (%s)" s.skill_name st)
        c.skills
    in
    let skills_block = String.concat "\n" skills_str in
    cat_header ^ "\n" ^ bar ^ "\n" ^ skills_block ^ "\n"

  let box_line width = String.make width '='

  let center_text width text =
    let len = String.length text in
    if len >= width then text
    else
      let left = (width - len) / 2 in
      String.make left ' ' ^ text

  let render_profile (profile : t) =
    let w = 50 in
    let top = box_line w in
    let title =
      center_text w (Printf.sprintf "User Profile: %s" profile.username)
    in
    let completed = total_completed profile in
    let rank, emoji = get_rank_and_emoji completed in
    let ranking_line =
      center_text w (Printf.sprintf "(Rank: %s %s)" rank emoji)
    in
    let cats = List.map render_category_block profile.categories in
    let bottom = box_line w in
    String.concat "\n" ([ top; title; ranking_line; top ] @ cats @ [ bottom ])

  let show_profile (profile : t) = print_endline (render_profile profile)
end
