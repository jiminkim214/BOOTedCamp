
type elt = User.t

type t = elt array ref

exception UserExists

let empty () : t = ref [||]


let contains (db : t) name =
  Array.mem name (Array.map (fun u -> User.get_name u) !db)

  let add_user (db : t) (user : elt) =
  if contains db (User.get_name user) then raise UserExists
  else db := Array.append !db [| user |]

(** [ load_csvt n] takes a string [n] that is the directoions to a file and
returns a Csv.t of the files contents. Raises [Sys_error] if the directory
  does not exist.*)
  let load_csvt n =
    Csv.load n

(** [csv_to_list n] takes a string [n] that is the directoions to a file and
returns a string list list of the files contents. Raises [Sys_error] if 
  the directory does not exist.*)
let csv_to_list (n: string) : string list list = load_csvt n


let load n =
  let l = csv_to_list n in
  let d = empty () in
  List.fold_left (fun acc row ->
    match row with
    | [a; b] -> add_user acc (User.create_user a b); acc
    | _ -> acc 
  ) d l

(** [db_to_list d] takes a t [d] and returns a string list list where each
  inner list has the first field being a user's name and the second field being
  the user's password.*)  
let db_to_list (d : t): string list list =
  let l = ref [] in
  for i = 0 to Array.length (!d) -1 do
    let u = !d.(i) in
    let n = User.get_name u in
    let p = User.get_password u in
    let temp = [n; p] in
    l := temp :: !l
  done;
  List.rev !l



let save n (d: t) = Csv.save n (db_to_list d)

 
let decrypt p = 
  let rec help acc s =
    if s = "" then acc
    else
      let h = String.sub s 0 1 in
      let t = String.sub s 1 (String.length s - 1) in
      let shifted = match h with
        | "a" -> "z"
        | "b" -> "a"
        | "c" -> "b"
        | "d" -> "c"
        | "e" -> "d"
        | "f" -> "e"
        | "g" -> "f"
        | "h" -> "g"
        | "i" -> "h"
        | "j" -> "i"
        | "k" -> "j"
        | "l" -> "k"
        | "m" -> "l"
        | "n" -> "m"
        | "o" -> "n"
        | "p" -> "o"
        | "q" -> "p"
        | "r" -> "q"
        | "s" -> "r"
        | "t" -> "s"
        | "u" -> "t"
        | "v" -> "u"
        | "w" -> "v"
        | "x" -> "w"
        | "y" -> "x"
        | "z" -> "y"
        | _ -> h
      in
      help (acc ^ shifted) t
  in
  help "" p


let check db n p = if contains db n then
  let all = !db in
  match Array.find_opt (fun u -> User.get_name u = n) all with
  | Some u ->
      let pass = User.get_password u in
      decrypt pass = p
  | None -> false
else
  false

let encrypt p = 
  let rec help acc s =
    if s = "" then acc
    else
      let h = String.sub s 0 1 in
      let t = String.sub s 1 (String.length s - 1) in
      let shifted = match h with
        | "a" -> "b"
        | "b" -> "c"
        | "c" -> "d"
        | "d" -> "e"
        | "e" -> "f"
        | "f" -> "g"
        | "g" -> "h"
        | "h" -> "i"
        | "i" -> "j"
        | "j" -> "k"
        | "k" -> "l"
        | "l" -> "m"
        | "m" -> "n"
        | "n" -> "o"
        | "o" -> "p"
        | "p" -> "q"
        | "q" -> "r"
        | "r" -> "s"
        | "s" -> "t"
        | "t" -> "u"
        | "u" -> "v"
        | "v" -> "w"
        | "w" -> "x"
        | "x" -> "y"
        | "y" -> "z"
        | "z" -> "a"
        | _ -> h
      in
      help (acc ^ shifted) t
  in
  help "" p
  


  