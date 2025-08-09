(* Web server to expose BOOTedCamp functionality via HTTP API *)

open Lwt.Syntax
open Cohttp_lwt_unix
open Yojson.Safe.Shortcuts

(* CORS headers for frontend integration *)
let cors_headers = [
  ("Access-Control-Allow-Origin", "*");
  ("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  ("Access-Control-Allow-Headers", "Content-Type, Authorization");
]

(* JSON response helper *)
let json_response ?(status=`OK) json_data =
  let body = Yojson.Safe.to_string json_data in
  Server.respond_string ~status ~headers:cors_headers ~body ()

(* Error response helper *)
let error_response ?(status=`Bad_request) message =
  let json = `Assoc [("error", `String message)] in
  json_response ~status json

(* Success response helper *)
let success_response data =
  let json = `Assoc [("success", `Bool true); ("data", data)] in
  json_response json

(* Parse JSON body *)
let parse_json_body body =
  try
    let json = Yojson.Safe.from_string body in
    Lwt.return (Some json)
  with
  | _ -> Lwt.return None

(* Extract JSON field *)
let get_string_field json field =
  try
    match json with
    | `Assoc assoc ->
      (match List.assoc field assoc with
       | `String s -> Some s
       | _ -> None)
    | _ -> None
  with
  | Not_found -> None

(* Convert skill to JSON *)
let skill_to_json (skill : BOOTedCamp.Tutorial.skill) =
  `Assoc [
    ("name", `String skill.name);
    ("description", `String skill.description);
    ("steps", `List (List.map (fun s -> `String s) skill.steps));
    ("video_links", `List (List.map (fun s -> `String s) skill.video_links));
  ]

(* Convert profile status to JSON *)
let status_to_json = function
  | BOOTedCamp.Profile.NotStarted -> `String "NotStarted"
  | BOOTedCamp.Profile.InProgress -> `String "InProgress" 
  | BOOTedCamp.Profile.Completed -> `String "Completed"

let status_from_string = function
  | "NotStarted" -> BOOTedCamp.Profile.NotStarted
  | "InProgress" -> BOOTedCamp.Profile.InProgress
  | "Completed" -> BOOTedCamp.Profile.Completed
  | _ -> BOOTedCamp.Profile.NotStarted

(* Convert profile to JSON *)
let profile_to_json (profile : BOOTedCamp.Profile.t) =
  let categories_json = List.map (fun category ->
    let skills_json = List.map (fun skill ->
      `Assoc [
        ("skill_name", `String skill.skill_name);
        ("description", `String skill.description);
        ("status", status_to_json skill.status);
      ]
    ) category.skills in
    `Assoc [
      ("category_name", `String category.category_name);
      ("skills", `List skills_json);
    ]
  ) profile.categories in
  `Assoc [
    ("username", `String profile.username);
    ("categories", `List categories_json);
  ]

(* Global state *)
let user_db = ref (BOOTedCamp.UserDB.load "data/users.csv")
let tutorials = ref []

(* Initialize tutorials *)
let init_tutorials () =
  let tutorial_data = BOOTedCamp.Run.load_tutorials_from_csv "data/skills.csv" in
  BOOTedCamp.Tutorial.set_tutorials tutorial_data;
  tutorials := tutorial_data

(* API Routes *)
let handle_login body =
  let* json_opt = parse_json_body body in
  match json_opt with
  | Some json ->
    let username = get_string_field json "username" in
    let password = get_string_field json "password" in
    (match username, password with
     | Some u, Some p ->
       if BOOTedCamp.UserDB.check !user_db u p then
         success_response (`Assoc [("username", `String u)])
       else
         error_response ~status:`Unauthorized "Invalid credentials"
     | _ -> error_response "Missing username or password")
  | None -> error_response "Invalid JSON"

let handle_signup body =
  let* json_opt = parse_json_body body in
  match json_opt with
  | Some json ->
    let username = get_string_field json "username" in
    let password = get_string_field json "password" in
    (match username, password with
     | Some u, Some p ->
       if BOOTedCamp.UserDB.contains !user_db u then
         error_response "Username already exists"
       else if not (String.for_all (function 'a'..'z' -> true | _ -> false) p) then
         error_response "Password must contain only lowercase letters"
       else (
         let encrypted_password = BOOTedCamp.UserDB.encrypt p in
         let new_user = BOOTedCamp.User.create_user u encrypted_password in
         BOOTedCamp.UserDB.add_user !user_db new_user;
         BOOTedCamp.UserDB.save "data/users.csv" !user_db;
         success_response (`Assoc [("username", `String u)])
       )
     | _ -> error_response "Missing username or password")
  | None -> error_response "Invalid JSON"

let handle_get_profile username =
  let profile = BOOTedCamp.Profile.load_or_init_profile ~username ~tutorials:!tutorials in
  success_response (profile_to_json profile)

let handle_update_skill_status username body =
  let* json_opt = parse_json_body body in
  match json_opt with
  | Some json ->
    let category = get_string_field json "category" in
    let skill_name = get_string_field json "skill_name" in
    let status_str = get_string_field json "status" in
    (match category, skill_name, status_str with
     | Some cat, Some skill, Some status ->
       let profile = BOOTedCamp.Profile.load_or_init_profile ~username ~tutorials:!tutorials in
       let new_status = status_from_string status in
       BOOTedCamp.Profile.update_skill_status profile ~category_name:cat ~skill_name:skill ~new_status;
       success_response (`Assoc [("updated", `Bool true)])
     | _ -> error_response "Missing required fields")
  | None -> error_response "Invalid JSON"

let handle_get_skills category =
  let skills = BOOTedCamp.Tutorial.list_skills category in
  let skills_json = List.map skill_to_json skills in
  success_response (`List skills_json)

let handle_get_skill category skill_name =
  match BOOTedCamp.Tutorial.get_tutorial category skill_name with
  | Some skill -> success_response (skill_to_json skill)
  | None -> error_response ~status:`Not_found "Skill not found"

let handle_get_categories () =
  let categories = List.map fst !tutorials in
  success_response (`List (List.map (fun c -> `String c) categories))

let handle_get_leaderboard () =
  (* Simple leaderboard implementation *)
  let users_data = BOOTedCamp.UserDB.get_all_users !user_db in
  let leaderboard = List.map (fun user ->
    let username = BOOTedCamp.User.get_name user in
    let profile = BOOTedCamp.Profile.load_or_init_profile ~username ~tutorials:!tutorials in
    let completed = BOOTedCamp.Profile.total_completed profile in
    let (rank, _) = BOOTedCamp.Profile.get_rank_and_emoji completed in
    `Assoc [
      ("username", `String username);
      ("completed_skills", `Int completed);
      ("rank", `String rank);
    ]
  ) users_data in
  let sorted_leaderboard = List.sort (fun a b ->
    let get_completed = function
      | `Assoc assoc -> (match List.assoc "completed_skills" assoc with `Int i -> i | _ -> 0)
      | _ -> 0
    in
    compare (get_completed b) (get_completed a)
  ) leaderboard in
  success_response (`List sorted_leaderboard)

(* Main request handler *)
let handler _conn req _body =
  let uri = Cohttp.Request.uri req in
  let meth = Cohttp.Code.string_of_method (Cohttp.Request.meth req) in
  let path = Uri.path uri in
  let* body_string = Cohttp_lwt.Body.to_string _body in
  
  (* Handle OPTIONS preflight requests *)
  if meth = "OPTIONS" then
    Server.respond_string ~status:`OK ~headers:cors_headers ~body:"" ()
  else
    match meth, String.split_on_char '/' path with
    | "POST", [""; "api"; "auth"; "login"] -> handle_login body_string
    | "POST", [""; "api"; "auth"; "signup"] -> handle_signup body_string
    | "GET", [""; "api"; "profile"; username] -> handle_get_profile username
    | "PUT", [""; "api"; "profile"; username; "skill"] -> handle_update_skill_status username body_string
    | "GET", [""; "api"; "skills"; category] -> handle_get_skills category
    | "GET", [""; "api"; "skill"; category; skill_name] -> handle_get_skill category skill_name
    | "GET", [""; "api"; "categories"] -> handle_get_categories ()
    | "GET", [""; "api"; "leaderboard"] -> handle_get_leaderboard ()
    | _ -> 
      error_response ~status:`Not_found ("Route not found: " ^ meth ^ " " ^ path)

(* Start server *)
let start_server port =
  init_tutorials ();
  Printf.printf "BOOTedCamp API Server starting on port %d\n" port;
  Printf.printf "Frontend should connect to: http://localhost:%d/api\n" port;
  let callback _conn req body = handler _conn req body in
  let server = Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ()) in
  server

let () =
  let port = try int_of_string (Sys.argv.(1)) with _ -> 8080 in
  Lwt_main.run (start_server port)
