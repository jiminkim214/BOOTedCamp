val add_comment :
  username:string ->
  category:string ->
  skill_name:string ->
  comment:string ->
  unit
(** [add_comment ~username ~category ~skill_name ~comment] adds a comment
    [comment] from a user [username] to the skill [skill_name] within the
    category [category]. The comment is saved for future reference. *)

val view_comments : category:string -> skill_name:string -> unit
(** [view_comments ~category ~skill_name] prints all comments associated with
    the skill [skill_name] in the category [category]. Each comment is displayed
    along with the username of the person who added it. *)

val load_comments : category:string -> skill_name:string -> string list list
(** [load_comments ~category ~skill_name] loads all comments for the skill
    [skill_name] in the category [category] and returns them as a list of lists.
    Each inner list represents a single comment, containing details such as the
    username and the comment text. *)
