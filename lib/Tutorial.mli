type skill = {
  name : string;
  description : string;
  steps : string list;
  video_links : string list;
}
(** [skill] is a record type representing a skill in a tutorial. It contains:
    - [name]: The name of the skill as a string.
    - [description]: A brief description of the skill as a string.
    - [steps]: A list of strings detailing the steps to perform the skill.
    - [video_links]: A list of strings containing URLs to video resources for
      the skill. *)

val set_tutorials : (string * skill list) list -> unit
(** [set_tutorials tutorials] sets the available tutorials to [tutorials], where
    [tutorials] is a list of tuples. Each tuple contains a category name as a
    string and a list of [skill] records for that category. *)

val get_tutorial : string -> string -> skill option
(** [get_tutorial category skill_name] retrieves the [skill] with the name
    [skill_name] from the category [category]. If the skill does not exist,
    returns [None]. *)

val list_skills : string -> skill list
(** [list_skills category] returns a list of all skills in the given [category].
    If the category does not exist, returns an empty list. *)
