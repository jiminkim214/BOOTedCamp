open Tutorial
open Profile
open Leaderboard (* Add the leaderboard module *)
open Achievements

(* Helper function to split a string by semicolon into a list *)
let split_semicolons s =
  let trimmed = String.trim s in
  if trimmed = "" then []
  else String.split_on_char ';' trimmed |> List.map String.trim

let render_progress_bar ~current ~total ~width =
  let filled_count =
    int_of_float
      (float_of_int current /. float_of_int total *. float_of_int width)
  in
  let unfilled_count = width - filled_count in
  let filled = String.concat "" (List.init filled_count (fun _ -> "🔵")) in
  let unfilled = String.concat "" (List.init unfilled_count (fun _ -> "⚪")) in
  Printf.sprintf "[%s%s] %d/%d" filled unfilled current total

let load_tutorials_from_csv file =
  let csv = Csv.load file in
  (* Expecting columns: category,name,description,steps,video_links *)
  let rec load_rows rows =
    match rows with
    | [] -> []
    | row :: rest -> (
        match row with
        | [ category; name; description; steps; video_links ] ->
            let steps_list = split_semicolons steps in
            let videos_list = split_semicolons video_links in
            let skill =
              {
                name;
                description;
                steps = steps_list;
                video_links = videos_list;
              }
            in
            let rest_data = load_rows rest in
            let updated_data =
              match List.assoc_opt category rest_data with
              | Some skills ->
                  (category, skill :: skills)
                  :: List.remove_assoc category rest_data
              | None -> (category, [ skill ]) :: rest_data
            in
            updated_data
        | _ ->
            failwith
              "Invalid CSV format. Expected 5 columns: \
               category,name,description,steps,video_links")
  in
  load_rows csv

let quit () =
  print_endline "Thank you for using Master Your Micro-Skills!";
  exit 0

let display_separator () = print_endline "\n----------------------\n"

let rec show_achievements_menu user_profile =
  (* Menu for further achievement-related actions *)
  print_endline "\n1. List All Achievements";
  print_endline "2. Check Progress to Next Achievement";
  print_endline "3. Go Back to Profile Menu";
  match read_line () with
  | "1" ->
      display_separator ();
      Achievements.list_all_achievements user_profile;
      show_achievements_menu user_profile (* Repeat the prompt *)
  | "2" ->
      display_separator ();
      Achievements.progress_to_next_achievement user_profile;
      show_achievements_menu user_profile (* Repeat the prompt *)
  | "3" -> profile_menu user_profile
  | _ ->
      print_endline "Invalid input.";
      show_achievements_menu user_profile

and show_achievements user_profile =
  display_separator ();
  print_endline "=== Achievements ===";
  let unlocked = Achievements.check_and_notify user_profile in
  if unlocked = [] then print_endline "No achievements unlocked yet."
  else
    List.iter
      (fun ach -> print_endline ("- " ^ Achievements.to_string ach))
      unlocked;
  (* Call the menu prompt *)
  show_achievements_menu user_profile

and profile_menu user_profile =
  display_separator ();
  print_endline "1. View Profile";
  print_endline "2. View Leaderboard";
  print_endline "3. View Achievements";
  print_endline "4. Go Back to Main Menu";
  print_endline "5. Quit";
  match read_line () with
  | "1" ->
      (* View Profile *)
      display_separator ();
      Profile.show_profile user_profile;
      profile_menu user_profile
  | "2" ->
      (* View Leaderboard *)
      display_separator ();
      Leaderboard.display_leaderboard ();
      profile_menu user_profile
  | "3" ->
      (* View Achievements *)
      show_achievements user_profile
  | "4" -> main_menu user_profile
  | "5" -> User.quit ()
  | _ ->
      print_endline "Invalid input.";
      profile_menu user_profile

and main_menu user_profile =
  display_separator ();
  print_endline "1. Browse";
  print_endline "2. Profile";
  print_endline "3. Quit";
  match read_line () with
  | "1" -> category_menu user_profile
  | "2" -> profile_menu user_profile
  | "3" -> User.quit ()
  | _ ->
      print_endline "Invalid input.";
      main_menu user_profile

and category_menu user_profile =
  display_separator ();
  let categories = user_profile.Profile.categories in
  List.iteri
    (fun i category ->
      let completed = Profile.completed_skills category in
      let total = Profile.total_skills category in
      let progress_bar =
        if total = 0 then "[⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪] No skills yet"
        else render_progress_bar ~current:completed ~total ~width:20
      in
      Printf.printf "%d. %s %s\n" (i + 1) category.category_name progress_bar)
    categories;
  print_endline (string_of_int (List.length categories + 1) ^ ". Go Back");
  print_endline (string_of_int (List.length categories + 2) ^ ". Quit");
  match read_line () with
  | input when int_of_string_opt input = Some (List.length categories + 1) ->
      main_menu user_profile
  | input when int_of_string_opt input = Some (List.length categories + 2) ->
      quit ()
  | input -> (
      match int_of_string_opt input with
      | Some n when n >= 1 && n <= List.length categories ->
          let category = List.nth categories (n - 1) in
          skill_menu user_profile category.category_name
      | _ ->
          print_endline "Invalid input.";
          category_menu user_profile)

and skill_menu user_profile category =
  display_separator ();
  let skills = Tutorial.list_skills category in
  List.iteri
    (fun i skill ->
      let rating =
        match Ratings.get_mean_rating ~category ~skill_name:skill.name with
        | Some r -> Printf.sprintf " (%.1f ★)" r
        | None -> " (No rating yet)"
      in
      Printf.printf "%d. %s%s\n" (i + 1) skill.name rating)
    skills;
  print_endline (string_of_int (List.length skills + 1) ^ ". Go Back");
  print_endline (string_of_int (List.length skills + 2) ^ ". Quit");
  match read_line () with
  | input when int_of_string_opt input = Some (List.length skills + 1) ->
      category_menu user_profile
  | input when int_of_string_opt input = Some (List.length skills + 2) ->
      quit ()
  | input -> (
      match int_of_string_opt input with
      | Some n when n >= 1 && n <= List.length skills ->
          let skill = List.nth skills (n - 1) in
          display_tutorial user_profile category skill
      | _ ->
          print_endline "Invalid input.";
          skill_menu user_profile category)

and display_tutorial user_profile category skill =
  let rec prompt_rating () =
    print_endline
      "\nWould you like to rate this skill? (1-5 or press Enter to skip)";
    match read_line () with
    | "" -> ()
    | input -> (
        match int_of_string_opt input with
        | Some rating when rating >= 1 && rating <= 5 ->
            Ratings.add_rating ~category ~skill_name:skill.name ~rating
              ~username:"default_user";
            print_endline "Thank you for rating!"
        | _ ->
            print_endline
              "Invalid rating. Please enter a number between 1 and 5.";
            prompt_rating ())
  in

  let rec show_menu () =
    print_endline "\n1. Mark as In Progress";
    print_endline "2. Mark as Completed";
    print_endline "3. View Comments";
    print_endline "4. Add a Comment";
    print_endline "5. Go Back";
    print_endline "6. Quit";
    match read_line () with
    | "1" ->
        Profile.update_skill_status user_profile ~category_name:category
          ~skill_name:skill.name ~new_status:Profile.InProgress;
        skill_menu user_profile category
    | "2" ->
        Profile.update_skill_status user_profile ~category_name:category
          ~skill_name:skill.name ~new_status:Profile.Completed;
        prompt_rating ();
        show_menu ()
    | "3" ->
        Comments.view_comments ~category ~skill_name:skill.name;
        show_menu ()
    | "4" ->
        print_string "Enter your comment: ";
        let user_comment = read_line () in
        Comments.add_comment ~username:user_profile.Profile.username ~category
          ~skill_name:skill.name ~comment:user_comment;
        print_endline "Comment added!";
        show_menu ()
    | "5" -> skill_menu user_profile category
    | "6" -> User.quit ()
    | _ ->
        print_endline "Invalid input.";
        show_menu ()
  in

  display_separator ();
  Printf.printf "Tutorial: %s\n%s\n" skill.name skill.description;

  (* Print steps if available *)
  if skill.steps <> [] then (
    print_endline "\nSteps:";
    List.iteri (fun i step -> Printf.printf "%d. %s\n" (i + 1) step) skill.steps);

  (* Print video links if available *)
  if skill.video_links <> [] then (
    print_endline "\nHelpful Video Links:";
    List.iter (fun link -> Printf.printf "- %s\n" link) skill.video_links);

  show_menu ()

let run username =
  let tutorials = load_tutorials_from_csv "data/skills.csv" in
  Tutorial.set_tutorials tutorials;
  let user_profile = Profile.load_or_init_profile ~username ~tutorials in
  main_menu user_profile
