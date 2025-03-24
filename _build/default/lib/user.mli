(** [t] is a reconrding representing a user with the field name and password,
with the name [name] of type string and  password of [password] of type string.
*)
type t = {
  mutable name : string;
  mutable password : string;
}

(** [create_user n p] creates a user with the name [n] and password [p] where
both must be strings.*)
val create_user : string -> string -> t

(** [get_name user] returns the name of a user [user].*)
val get_name : t -> string

(** [get_password user] returns the password of a user [user].*)
val get_password : t -> string

(** [quit ()] prints "Thank you for using Master Your Micro-Skills!" and
exits the program..*)
val quit : unit -> unit
