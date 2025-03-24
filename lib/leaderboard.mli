val ensure_file_exists : unit -> unit
(** [ensure_file_exists ()] ensures that the leaderboard file exists in the
    expected location. If the file does not exist, it is created as an empty
    file. *)

val update_leaderboard : string -> int -> unit
(** [update_leaderboard username score] updates the leaderboard by recording the
    [score] for the user identified by [username]. If the user already exists on
    the leaderboard, their score is updated. If not, a new entry is added. *)

val rank_users : unit -> (int * string list) list
(** [rank_users ()] retrieves all users and their scores from the leaderboard,
    ranks them in descending order of scores, and returns a list of ranked
    users. Each entry in the list is a tuple containing the rank (starting from
    1) and a list of user details (username and score). *)

val display_leaderboard : unit -> unit
(** [display_leaderboard ()] prints the leaderboard to the console in a
    formatted and ranked order, showing the rank, username, and score for each
    user. *)

val load_leaderboard : unit -> string list list
(** [load_leaderboard ()] loads the current leaderboard from the file and
    returns its contents as a list of lists of strings. Each inner list
    represents a row, containing details such as the username and score. *)
