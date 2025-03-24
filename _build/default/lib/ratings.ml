let ratings_file = "data/skill_ratings.csv"

(* Ensure the ratings file exists *)
let ensure_file_exists () =
  if not (Sys.file_exists ratings_file) then Csv.save ratings_file []

(* Add a rating to the file *)
let add_rating ~category ~skill_name ~rating ~username =
  ensure_file_exists ();
  let rows = Csv.load ratings_file in
  let new_row = [ category; skill_name; username; string_of_int rating ] in
  Csv.save ratings_file (rows @ [ new_row ])

(* Get all ratings for a skill *)
let get_ratings ~category ~skill_name =
  ensure_file_exists ();
  let rows = Csv.load ratings_file in
  List.filter_map
    (fun row ->
      match row with
      | [ cat; skill; _user; rating ] when cat = category && skill = skill_name
        -> Some (int_of_string rating)
      | _ -> None)
    rows

(* Calculate the mean rating for a skill *)
let get_mean_rating ~category ~skill_name =
  let ratings = get_ratings ~category ~skill_name in
  match ratings with
  | [] -> None
  | ratings ->
      let sum = List.fold_left ( + ) 0 ratings in
      Some (float_of_int sum /. float_of_int (List.length ratings))

let get_all_user_ratings username =
  let rows = Csv.load ratings_file in
  List.filter_map
    (fun row ->
      match row with
      | [ _; _; user; rating ] when user = username ->
          Some (float_of_string rating)
      | _ -> None)
    rows
