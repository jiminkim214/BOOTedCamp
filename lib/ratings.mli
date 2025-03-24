val add_rating :
  category:string -> skill_name:string -> rating:int -> username:string -> unit
(** [add_rating ~category ~skill_name ~rating ~username] adds a [rating] given
    by a user identified by [username] for the skill [skill_name] within the
    category [category]. The rating is stored for future reference and analysis. *)

val get_mean_rating : category:string -> skill_name:string -> float option
(** [get_mean_rating ~category ~skill_name] computes and returns the mean rating
    for the skill [skill_name] in the category [category]. If no ratings exist
    for the skill, it returns [None]. *)

val get_all_user_ratings : string -> float list
(** [get_all_user_ratings username] retrieves all ratings provided by the user
    identified by [username]. It returns a list of all rating values as floats. *)

val get_ratings : category:string -> skill_name:string -> int list
(** [get_ratings ~category ~skill_name] retrieves all ratings given for the
    skill [skill_name] in the category [category]. It returns a list of all
    rating values as integers. *)
