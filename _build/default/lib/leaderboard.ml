let leaderboard_file = "data/leaderboard.csv"

(* Ensure leaderboard file exists *)
let ensure_file_exists () =
  if not (Sys.file_exists leaderboard_file) then Csv.save leaderboard_file []

(* Load leaderboard data *)
let load_leaderboard () =
  ensure_file_exists ();
  Csv.load leaderboard_file

(* Update or add a user's score *)
let update_leaderboard username completed_skills =
  ensure_file_exists ();
  let rows = load_leaderboard () in
  let updated_rows =
    let filtered = List.filter (fun row -> List.hd row <> username) rows in
    filtered @ [ [ username; string_of_int completed_skills ] ]
  in
  Csv.save leaderboard_file updated_rows

(* Rank users by completed skills *)
let rank_users () =
  let rows = load_leaderboard () in
  let sorted =
    List.sort
      (fun a b ->
        compare (int_of_string (List.nth b 1)) (int_of_string (List.nth a 1)))
      rows
  in
  List.mapi (fun i row -> (i + 1, row)) sorted

(* Display leaderboard *)
let display_leaderboard () =
  print_endline "\n=== Leaderboard ===";
  let rankings = rank_users () in
  match rankings with
  | [] -> print_endline "No users on the leaderboard yet!"
  | _ ->
      List.iter
        (fun (rank, row) ->
          Printf.printf "%d. %s - %s skills completed\n" rank (List.nth row 0)
            (List.nth row 1))
        rankings
