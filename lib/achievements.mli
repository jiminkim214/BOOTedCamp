open Profile

(** [t] is a type representing an achievement. It can be:
    - [SkillMaster of int]: Unlocked when the user completes a specific number
      of skills.
    - [ConsistentLearner]: Unlocked when the user consistently engages with
      learning activities.
    - [HighRatingGiver]: Unlocked when the user provides high ratings for
      skills. *)
type t =
  | SkillMaster of int
  | ConsistentLearner
  | HighRatingGiver

val to_string : t -> string
(** [to_string a] converts an achievement [a] into a string representation. *)

val is_unlocked : Profile.t -> t -> bool
(** [is_unlocked profile a] checks if the achievement [a] has been unlocked for
    the given user [profile]. *)

val list_all_achievements : Profile.t -> unit
(** [list_all_achievements profile] prints all achievements for the user
    associated with the given [profile] and indicates whether each has been
    unlocked. *)

val progress_to_next_achievement : Profile.t -> unit
(** [progress_to_next_achievement profile] determines the user's progress toward
    the next achievable milestone and prints relevant information for the given
    [profile]. *)

val save_unlocked_achievements : string -> t list -> unit
(** [save_unlocked_achievements username achievements] saves the list of
    unlocked achievements [achievements] for the user with the given [username]. *)

val load_unlocked_achievements : string -> string list
(** [load_unlocked_achievements username] loads the list of unlocked
    achievements for the user with the given [username]. Returns a list of
    achievement names as strings. *)

val check_and_notify : Profile.t -> t list
(** [check_and_notify profile achievements] checks for newly unlocked
    achievements based on the user's current [profile] and the list of
    achievements [achievements]. Notifies the user if any new achievements have
    been unlocked. *)
