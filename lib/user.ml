type t = {
  mutable name : string;
  mutable password : string;
}


let create_user n p  = { name = n; password = p }

let get_name user = user.name

let get_password user = user.password

let quit () = 
  print_endline "Thank you for using Master Your Micro-Skills!";
  exit 0 [@@coverage off]