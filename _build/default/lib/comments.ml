let comment_file = "data/skill_comments.csv"

(* Ensure the comment file exists, if not, create an empty file *)
let ensure_file_exists () =
  if not (Sys.file_exists comment_file) then Csv.save comment_file []

(* Add a comment to the CSV file *)
let add_comment ~username ~category ~skill_name ~comment =
  ensure_file_exists ();
  let rows = Csv.load comment_file in
  let new_row = [ category; skill_name; username; comment ] in
  Csv.save comment_file (rows @ [ new_row ])

(* Load comments for a given category and skill *)
let load_comments ~category ~skill_name =
  ensure_file_exists ();
  let rows = Csv.load comment_file in
  List.filter
    (fun row ->
      match row with
      | [ cat; skill; _user; _comment ] -> cat = category && skill = skill_name
      | _ -> false)
    rows

(* Display comments for a skill *)
let view_comments ~category ~skill_name =
  let comments = load_comments ~category ~skill_name in
  if comments = [] then
    print_endline "No comments yet. Be the first to comment!"
  else begin
    print_endline "\n=== Comments ===";
    List.iter
      (fun row ->
        match row with
        | [ _cat; _skill; user; comment ] ->
            Printf.printf "%s: %s\n" user comment
        | _ -> ())
      comments;
    print_endline "==============\n"
  end
