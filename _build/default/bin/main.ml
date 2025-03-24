(* main.ml *)
let lower s =
  let len = String.length s in
  let rec help i =
    if i = len then true
    else
      let c = s.[i] in
      if List.mem c ['a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'; 'i'; 'j'; 'k'; 'l'; 'm';
                     'n'; 'o'; 'p'; 'q'; 'r'; 's'; 't'; 'u'; 'v'; 'w'; 'x'; 'y'; 'z']
      then help (i + 1)
      else false
  in
  help 0

let r msg =
  Printf.printf "%s" msg;
  String.trim (read_line ())

let rec login_password db username =
  let password = r "Enter your password (or type 'menu' to return to the main menu): " in
  if password = "menu" then
    None
  else if BOOTedCamp.UserDB.check db username password then
    Some username
  else (
    Printf.printf "Incorrect password. Try again.\n";
    login_password db username
  )

let rec login db : string option =
  let username = r "Enter your username (or type 'menu' to return to the main menu): " in
  if username = "menu" then
    None
  else if BOOTedCamp.UserDB.contains db username then
    login_password db username
  else (
    Printf.printf "Username does not exist. Try again.\n";
    login db
  )

(* Separate function to prompt for a valid username during signup *)
let rec signup_username db : string option =
  let username = r "Enter username (or type 'menu' to return to the main menu): " in
  if username = "menu" then
    None
  else if BOOTedCamp.UserDB.contains db username then (
    Printf.printf "Username already exists. Use a different name.\n";
    signup_username db
  ) else
    Some username

(* Separate function to prompt for a valid password for the given username during signup *)
let rec signup_password db username : string option =
  let password = r "Enter password (or type 'menu' to return to the main menu): " in
  if password = "menu" then
    None
  else if not (lower password) then (
    Printf.printf "Our password encryption is bad, only enter lowercase letters.\n";
    (* Re-prompt for password without returning to username prompt *)
    signup_password db username
  ) else (
    let encrypted_password = BOOTedCamp.UserDB.encrypt password in
    let new_user = BOOTedCamp.User.create_user username encrypted_password in
    BOOTedCamp.UserDB.add_user db new_user;
    BOOTedCamp.UserDB.save "data/users.csv" db;
    Printf.printf "Account created successfully. Enjoy, %s!\n" username;
    Some username
  )

let signup db : string option =
  match signup_username db with
  | None -> None
  | Some username -> signup_password db username

let rec front_menu db =
  Printf.printf "Log in or sign up?\n";
  Printf.printf "1. Login\n";
  Printf.printf "2. Sign up\n";
  Printf.printf "3. Quit\n";
  match String.trim (read_line ()) with
  | "1" -> (
      match login db with
      | Some username -> username
      | None -> front_menu db
    )
  | "2" -> (
      match signup db with
      | Some username -> username
      | None -> front_menu db
    )
  | "3" -> BOOTedCamp.User.quit (); exit 0
  | _ ->
      Printf.printf "Enter 1, 2, or 3.\n";
      front_menu db

let main () =
  Printf.printf "Welcome to Microskills!\n";
  let db = BOOTedCamp.UserDB.load "data/users.csv" in
  let username = front_menu db in
  BOOTedCamp.Run.run username

let () = main ()
