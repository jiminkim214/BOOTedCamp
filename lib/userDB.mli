type elt = User.t
(** [elt] represents a single user in the databse.*)

type t = elt array ref
(** [t] represents a database of uses stored as a referenced array of [elt].*)

val empty : unit -> t
(** [empty ()] returns a t with no users.*)

exception UserExists
(** [UserExists] raised when you try to add a user into a databse which already
    has a user with the same name.*)

val contains : t -> string -> bool
(** [contains db name] returns true if string [name] matches a name of a user in
    t [db] and false otherwise *)

val add_user : t -> elt -> unit
(** [add_user db user] adds elt [user] to t [db] if there isn't already a user
    with the same name. If the name is taken it raises [UserExists] *)

val load : string -> t
(** [load n] takes a string [n] that is the directoions to a file and returns a
    t where the first column is the name of the user and second column is the
    encrypted password of the user. Each row is a user. It returns the resulting
    t when it reaches a row that doesn't have exactly 2 columns.*)

val save : string -> t -> unit
(** [save n d] takes a string [n] and a t [d]. It saves the users of [d] into a
    csv file with the directory [n]. Each row is a user where the first column
    is the user's name and the second column is the user's encrypted password.*)

val check : t -> string -> string -> bool
(** [check db n p] returns true if a user is contained in t [db] that has the
    name [n] and password [p] and returns false otherwise.*)

val encrypt : string -> string
(** [encrypt p] takes a string [p] and performs a one shift cypher on the
    lowercase letters in it. This means that "a" is converted to "b", "b" is
    converted to "c", "z" is converted to "a" and so on. It returns the
    resulting string without changing none-lowercase letters.*)

val decrypt : string -> string
(** [decrypt p] takes a string [p] and performs a -1 shift cypher on the
    lowercase letters in it. This means that "a" is converted to "z", "b" is
    converted to "a", "z" is converted to "y" and so on. It returns the
    resulting string without changing none-lowercase letters.*)
