open Profile

let achievements_file = "data/achievements.csv"

type t =
  | SkillMaster of int (* Number of completed skills *)
  | ConsistentLearner (* At least one skill completed in each category *)
  | HighRatingGiver (* Average rating of 4+ *)

let to_string = function
  | SkillMaster n -> Printf.sprintf "Skill Master (%d skills completed)" n
  | ConsistentLearner ->
      "Consistent Learner (Completed one skill in each category)"
  | HighRatingGiver -> "High Rating Giver (Average rating of 4+)"

(* Ensure the achievements file exists *)
let ensure_file_exists () =
  if not (Sys.file_exists achievements_file) then Csv.save achievements_file []

(* Save unlocked achievements for a user *)
let save_unlocked_achievements username unlocked =
  ensure_file_exists ();
  let rows = Csv.load achievements_file in
  let new_rows = List.map (fun ach -> [ username; to_string ach ]) unlocked in
  Csv.save achievements_file (rows @ new_rows)

(* Load unlocked achievements for a user *)
let load_unlocked_achievements username =
  ensure_file_exists ();
  let rows = Csv.load achievements_file in
  List.filter_map
    (fun row ->
      match row with
      | [ user; achievement ] when user = username -> Some achievement
      | _ -> None)
    rows

(* Check if an achievement is unlocked *)
let is_unlocked user_profile achievement =
  match achievement with
  | SkillMaster n -> Profile.total_completed user_profile >= n
  | ConsistentLearner ->
      List.for_all
        (fun category -> Profile.completed_skills category > 0)
        user_profile.Profile.categories
  | HighRatingGiver ->
      let ratings =
        Ratings.get_all_user_ratings user_profile.Profile.username
      in
      let total = List.length ratings in
      if total = 0 then false
      else
        let sum = List.fold_left ( +. ) 0.0 ratings in
        sum /. float_of_int total >= 4.0

(* List all achievements with status *)
let list_all_achievements user_profile =
  let all_achievements =
    [ SkillMaster 5; SkillMaster 10; ConsistentLearner; HighRatingGiver ]
  in
  List.iter
    (fun ach ->
      let status =
        if is_unlocked user_profile ach then "Unlocked" else "Locked"
      in
      Printf.printf "- %s [%s]\n" (to_string ach) status)
    all_achievements

(* Progress toward the next achievement *)
let progress_to_next_achievement user_profile =
  let all_achievements =
    [ SkillMaster 5; SkillMaster 10; ConsistentLearner; HighRatingGiver ]
  in
  let locked =
    List.filter (fun ach -> not (is_unlocked user_profile ach)) all_achievements
  in
  match locked with
  | [] -> print_endline "Congratulations! You have unlocked all achievements!"
  | ach :: _ -> (
      match ach with
      | SkillMaster n ->
          let completed = Profile.total_completed user_profile in
          Printf.printf "Progress to next achievement: %d/%d skills completed\n"
            completed n
      | ConsistentLearner ->
          let categories = user_profile.Profile.categories in
          let completed_categories =
            List.filter (fun c -> Profile.completed_skills c > 0) categories
            |> List.length
          in
          Printf.printf
            "Progress to 'Consistent Learner': %d/%d categories completed\n"
            completed_categories (List.length categories)
      | HighRatingGiver ->
          let ratings =
            Ratings.get_all_user_ratings user_profile.Profile.username
          in
          let total = List.length ratings in
          if total = 0 then
            print_endline
              "Progress to 'High Rating Giver': No ratings given yet."
          else
            let sum = List.fold_left ( +. ) 0.0 ratings in
            let avg = sum /. float_of_int total in
            Printf.printf
              "Progress to 'High Rating Giver': Average rating %.1f/4.0\n" avg)

let check_and_notify user_profile =
  let all_achievements =
    [ SkillMaster 5; SkillMaster 10; ConsistentLearner; HighRatingGiver ]
  in
  let unlocked =
    List.filter (fun ach -> is_unlocked user_profile ach) all_achievements
  in
  List.iter
    (fun ach -> print_endline ("🎉 Achievement Unlocked: " ^ to_string ach))
    unlocked;
  unlocked
