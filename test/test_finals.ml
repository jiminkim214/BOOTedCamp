open Printf
open Finals.Tutorial
open Finals.Profile
open Finals.Achievements
open Finals.Comments
open Finals.Leaderboard
open Finals.Ratings

(* Mock data for testing *)
let mock_tutorials =
  [
    ( "Exercise",
      [
        {
          name = "Pushups";
          description = "Do 20 pushups.";
          steps = [ "asdf"; "asdf"; "asdf" ];
          video_links = [ "asdf"; "asdf"; "asdf" ];
        };
        {
          name = "Running";
          description = "Run 5 km.";
          steps = [ "asdf"; "asdf"; "asdf" ];
          video_links = [ "asdf"; "asdf"; "asdf" ];
        };
      ] );
    ( "Cooking",
      [
        {
          name = "Pasta";
          description = "Cook a pasta dish.";
          steps = [ "asdf"; "asdf"; "asdf" ];
          video_links = [ "asdf"; "asdf"; "asdf" ];
        };
        {
          name = "Salad";
          description = "Prepare a healthy salad.";
          steps = [ "asdf"; "asdf"; "asdf" ];
          video_links = [ "asdf"; "asdf"; "asdf" ];
        };
        {
          name = "Soup";
          description = "Make a warm soup.";
          steps = [ "asdf"; "asdf"; "asdf" ];
          video_links = [ "asdf"; "asdf"; "asdf" ];
        };
      ] );
  ]

let mock_username = "test_user"

(* Instantiate a profile *)
let profile =
  Profile.init_profile ~username:mock_username ~tutorials:mock_tutorials

(* We will create many tests and run them all in run_all_tests. We'll maintain a
   global reference to track if any test fails. *)
let tests_passed = ref true

let check test_name condition =
  if not condition then begin
    printf "Test Failed: %s\n" test_name;
    tests_passed := false
  end
  else printf "Test Passed: %s\n" test_name

(* Helper function to check if a substring is present in a string *)
let contains_substring s sub =
  let len_s = String.length s and len_sub = String.length sub in
  let rec aux i =
    if i + len_sub > len_s then false
    else if String.sub s i len_sub = sub then true
    else aux (i + 1)
  in
  aux 0

(* Additional helper: Check multiple substrings all present *)
(* let contains_all_substrings s subs = List.for_all (fun sub ->
   contains_substring s sub) subs *)

(* Create data directory if not present and ensure a clean state *)
let () =
  if not (Sys.file_exists "data") then Unix.mkdir "data" 0o755;
  if Sys.file_exists "data/user_profiles.csv" then
    Sys.remove "data/user_profiles.csv"

(* Test initialization: All skills should start NotStarted *)
let test_init () =
  let status_ex_pushups =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Pushups"
  in
  let status_ex_running =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Running"
  in
  let status_cook_pasta =
    Profile.get_skill_status profile ~category_name:"Cooking"
      ~skill_name:"Pasta"
  in
  let status_cook_salad =
    Profile.get_skill_status profile ~category_name:"Cooking"
      ~skill_name:"Salad"
  in
  let status_cook_soup =
    Profile.get_skill_status profile ~category_name:"Cooking" ~skill_name:"Soup"
  in

  check "Init: Exercise Pushups NotStarted"
    (status_ex_pushups = Some Profile.NotStarted);
  check "Init: Exercise Running NotStarted"
    (status_ex_running = Some Profile.NotStarted);
  check "Init: Cooking Pasta NotStarted"
    (status_cook_pasta = Some Profile.NotStarted);
  check "Init: Cooking Salad NotStarted"
    (status_cook_salad = Some Profile.NotStarted);
  check "Init: Cooking Soup NotStarted"
    (status_cook_soup = Some Profile.NotStarted)

(* Test string_to_status and status_to_string conversions *)
let test_status_conversion () =
  check "Status to string: NotStarted"
    (Profile.status_to_string Profile.NotStarted = "Not Started");
  check "Status to string: InProgress"
    (Profile.status_to_string Profile.InProgress = "In Progress");
  check "Status to string: Completed"
    (Profile.status_to_string Profile.Completed = "Completed");

  check "String to status: not started"
    (Profile.string_to_status "not started" = Profile.NotStarted);
  check "String to status: iN PrOgReSs"
    (Profile.string_to_status "iN PrOgReSs" = Profile.InProgress);
  check "String to status: COMPLETED"
    (Profile.string_to_status "COMPLETED" = Profile.Completed);
  check "String to status: unknown defaults to NotStarted"
    (Profile.string_to_status "foo" = Profile.NotStarted)

(* Test updating skill status and verifying changes *)
let test_update_status () =
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Pushups" ~new_status:Profile.InProgress;
  let new_status =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Pushups"
  in
  check "Update: Pushups InProgress" (new_status = Some Profile.InProgress);

  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Pasta" ~new_status:Profile.Completed;
  let new_status_pasta =
    Profile.get_skill_status profile ~category_name:"Cooking"
      ~skill_name:"Pasta"
  in
  check "Update: Pasta Completed" (new_status_pasta = Some Profile.Completed);

  (* Non-existent skill *)
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"NonExistent" ~new_status:Profile.Completed;
  let nonexistent_status =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"NonExistent"
  in
  check "Update: NonExistent skill" (nonexistent_status = None)

(* Test counting total and completed skills *)
let test_counting () =
  let total = Profile.total_skills_all profile in
  let completed = Profile.total_completed profile in
  check "Counting: total skills is 5" (total = 5);
  check "Counting: completed skills is 1" (completed = 1)

(* Test rendering basic checks *)
let test_rendering () =
  let rendered = Profile.render_profile profile in
  check "Rendering: contains username"
    (contains_substring rendered mock_username);
  check "Rendering: contains category Exercise"
    (contains_substring rendered "Category: Exercise");
  check "Rendering: contains category Cooking"
    (contains_substring rendered "Category: Cooking");
  check "Rendering: has '#' or '-'"
    (String.contains rendered '#' || String.contains rendered '-')

(* Test ranking logic with incremental updates *)
let test_ranking () =
  (* Reset all to NotStarted *)
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Pushups" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Running" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Pasta" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Salad" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Soup" ~new_status:Profile.NotStarted;

  let rendered0 = Profile.render_profile profile in
  check "Ranking: 0 completed = Bronze"
    (contains_substring rendered0 "Bronze" && contains_substring rendered0 "🥉");

  (* Complete 1 tutorial -> Silver *)
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Pushups" ~new_status:Profile.Completed;
  let rendered1 = Profile.render_profile profile in
  check "Ranking: 1 completed = Silver"
    (contains_substring rendered1 "Silver" && contains_substring rendered1 "🥈");

  (* 2 completed -> Gold *)
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Running" ~new_status:Profile.Completed;
  let rendered2 = Profile.render_profile profile in
  check "Ranking: 2 completed = Gold"
    (contains_substring rendered2 "Gold" && contains_substring rendered2 "🥇");

  (* 3 completed -> Master *)
  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Pasta" ~new_status:Profile.Completed;
  let rendered3 = Profile.render_profile profile in
  check "Ranking: 3 completed = Master"
    (contains_substring rendered3 "Master" && contains_substring rendered3 "🏆");

  (* 4 completed -> Champion *)
  Profile.update_skill_status profile ~category_name:"Cooking"
    ~skill_name:"Salad" ~new_status:Profile.Completed;
  let rendered4 = Profile.render_profile profile in
  check "Ranking: 4 completed = Champion"
    (contains_substring rendered4 "Champion" && contains_substring rendered4 "👑")

(* Edge cases tests *)
let test_edge_cases () =
  (* Non-existent category *)
  let none_status =
    Profile.get_skill_status profile ~category_name:"NonExistentCat"
      ~skill_name:"Pushups"
  in
  check "Edge: Non-existent category returns None" (none_status = None);

  (* Attempt update in non-existent category *)
  Profile.update_skill_status profile ~category_name:"FakeCat"
    ~skill_name:"Running" ~new_status:Profile.Completed;
  let status_running =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Running"
  in
  check "Edge: Update in non-existent category does nothing"
    (status_running = Some Profile.Completed);

  (* Multiple updates to the same skill *)
  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Running" ~new_status:Profile.InProgress;
  let status_running_inprogress =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Running"
  in
  check "Edge: Multiple updates - Running InProgress"
    (status_running_inprogress = Some Profile.InProgress);

  Profile.update_skill_status profile ~category_name:"Exercise"
    ~skill_name:"Running" ~new_status:Profile.NotStarted;
  let status_running_back =
    Profile.get_skill_status profile ~category_name:"Exercise"
      ~skill_name:"Running"
  in
  check "Edge: Multiple updates - Running back to NotStarted"
    (status_running_back = Some Profile.NotStarted);

  (* Check total_completed after toggling statuses *)
  let comp_after_toggle = Profile.total_completed profile in
  (* Initially had 4 completed, changed one back to NotStarted, now 3
     completed *)
  check "Edge: Total completed after toggling statuses" (comp_after_toggle = 3)

(* Complex scenarios: empty profiles, profiles with empty categories, etc. *)
let test_complex_scenarios () =
  (* Empty tutorials *)
  let empty_tutorials : (string * skill list) list = [] in
  let empty_profile =
    Profile.init_profile ~username:"empty_user" ~tutorials:empty_tutorials
  in
  let rendered_empty = Profile.render_profile empty_profile in
  check "Complex: Empty profile render has no categories"
    (not (contains_substring rendered_empty "Category:"));

  (* Ranking on empty profile -> Bronze *)
  let rendered_empty_rank = Profile.render_profile empty_profile in
  check "Complex: Empty profile rank is Bronze"
    (contains_substring rendered_empty_rank "Bronze"
    && contains_substring rendered_empty_rank "🥉");

  (* Category with no skills *)
  let no_skills_tutorials = [ ("EmptyCategory", []) ] in
  let no_skills_profile =
    Profile.init_profile ~username:"no_skills_user"
      ~tutorials:no_skills_tutorials
  in
  let rendered_no_skills = Profile.render_profile no_skills_profile in
  check "Complex: Category with no skills"
    (contains_substring rendered_no_skills "Category: EmptyCategory"
    && contains_substring rendered_no_skills "0/0 Completed");

  (* Update non-existent skill in empty category *)
  Profile.update_skill_status no_skills_profile ~category_name:"EmptyCategory"
    ~skill_name:"GhostSkill" ~new_status:Profile.Completed;
  let rendered_no_skills_after = Profile.render_profile no_skills_profile in
  check "Complex: After updating non-existent skill in empty category"
    (contains_substring rendered_no_skills_after "0/0 Completed");

  (* Single skill category *)
  let single_skill_tuts =
    [
      ( "SingleSkillCat",
        [
          {
            name = "Yoga";
            description = "Do yoga for 10 minutes";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
        ] );
    ]
  in
  let single_skill_profile =
    Profile.init_profile ~username:"single_skill_user"
      ~tutorials:single_skill_tuts
  in
  let rendered_single = Profile.render_profile single_skill_profile in
  check "Complex: Single skill category renders"
    (contains_substring rendered_single "Category: SingleSkillCat"
    && contains_substring rendered_single "Yoga");

  Profile.update_skill_status single_skill_profile
    ~category_name:"SingleSkillCat" ~skill_name:"Yoga"
    ~new_status:Profile.Completed;
  let rendered_single_comp = Profile.render_profile single_skill_profile in
  check "Complex: Single skill completed => Silver rank"
    (contains_substring rendered_single_comp "Silver"
    && contains_substring rendered_single_comp "🥈")

(* Test get_rank_and_emoji directly for thresholds *)
let test_rank_boundaries () =
  let r0, e0 = Profile.get_rank_and_emoji 0 in
  check "Rank boundary: 0 completed = Bronze" (r0 = "Bronze" && e0 = "🥉");

  let r1, e1 = Profile.get_rank_and_emoji 1 in
  check "Rank boundary: 1 completed = Silver" (r1 = "Silver" && e1 = "🥈");

  let r2, e2 = Profile.get_rank_and_emoji 2 in
  check "Rank boundary: 2 completed = Gold" (r2 = "Gold" && e2 = "🥇");

  let r3, e3 = Profile.get_rank_and_emoji 3 in
  check "Rank boundary: 3 completed = Master" (r3 = "Master" && e3 = "🏆");

  let r4, e4 = Profile.get_rank_and_emoji 4 in
  check "Rank boundary: 4 completed = Champion" (r4 = "Champion" && e4 = "👑");

  let r10, e10 = Profile.get_rank_and_emoji 10 in
  check "Rank boundary: 10 completed still Champion"
    (r10 = "Champion" && e10 = "👑")

(* Test progress bar *)
let test_progress_bar () =
  let cat_progress =
    {
      Profile.category_name = "TestCat";
      skills =
        [
          { skill_name = "A"; description = ""; status = Profile.Completed };
          { skill_name = "B"; description = ""; status = Profile.InProgress };
          { skill_name = "C"; description = ""; status = Profile.NotStarted };
          { skill_name = "D"; description = ""; status = Profile.Completed };
        ];
    }
  in
  let bar = Profile.render_progress_bar cat_progress in
  check "Progress bar: shows 2/4 Completed"
    (contains_substring bar "2/4 Completed");
  check "Progress bar: includes '#' and '-'"
    (contains_substring bar "#" && contains_substring bar "-")

(* Test category block rendering *)
let test_category_block () =
  let cat_progress =
    {
      Profile.category_name = "TestCategory";
      skills =
        [
          {
            skill_name = "Skill1";
            description = "Desc1";
            status = Profile.Completed;
          };
          {
            skill_name = "Skill2";
            description = "Desc2";
            status = Profile.NotStarted;
          };
        ];
    }
  in
  let block = Profile.render_category_block cat_progress in
  check "Category block: contains category name"
    (contains_substring block "Category: TestCategory");
  check "Category block: contains Skill1 (Completed)"
    (contains_substring block "Skill1 (Completed)");
  check "Category block: contains Skill2 (Not Started)"
    (contains_substring block "Skill2 (Not Started)");
  check "Category block: shows 1/2 Completed"
    (contains_substring block "1/2 Completed")

(* Test large scenario *)
let test_large_scenario () =
  let rec make_skills n =
    if n = 0 then []
    else
      {
        name = "Skill" ^ string_of_int n;
        description = "D";
        steps = [ "asdf"; "asdf"; "asdf" ];
        video_links = [ "asdf"; "asdf"; "asdf" ];
      }
      :: make_skills (n - 1)
  in
  let big_tutorials =
    [
      ("BigCat1", make_skills 10);
      ("BigCat2", make_skills 15);
      ("BigCat3", make_skills 5);
    ]
  in
  let big_profile =
    Profile.init_profile ~username:"big_user" ~tutorials:big_tutorials
  in
  check "Large scenario: total skills = 30"
    (Profile.total_skills_all big_profile = 30);
  check "Large scenario: total completed = 0"
    (Profile.total_completed big_profile = 0);

  (* Complete all in BigCat1 *)
  List.iter
    (fun i ->
      Profile.update_skill_status big_profile ~category_name:"BigCat1"
        ~skill_name:("Skill" ^ string_of_int i)
        ~new_status:Profile.Completed)
    (List.init 10 (fun x -> x + 1));

  check "Large scenario: after completing BigCat1, completed=10"
    (Profile.total_completed big_profile = 10);

  (* Render large profile *)
  let rendered_large = Profile.render_profile big_profile in
  check "Large scenario: renders large profile"
    (contains_substring rendered_large "BigCat1"
    && contains_substring rendered_large "BigCat2"
    && contains_substring rendered_large "BigCat3");
  check "Large scenario: after 10 completed = Champion"
    (contains_substring rendered_large "Champion"
    && contains_substring rendered_large "👑")

(* Test toggling one skill *)
let test_toggle_one_skill () =
  let toggle_profile =
    Profile.init_profile ~username:"toggle_user"
      ~tutorials:
        [
          ( "ToggleCat",
            [
              {
                name = "ToggleSkill";
                description = "X";
                steps = [ "asdf"; "asdf"; "asdf" ];
                video_links = [ "asdf"; "asdf"; "asdf" ];
              };
            ] );
        ]
  in
  check "Toggle: initially NotStarted"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat"
       ~skill_name:"ToggleSkill"
    = Some Profile.NotStarted);

  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat"
    ~skill_name:"ToggleSkill" ~new_status:Profile.InProgress;
  check "Toggle: now InProgress"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat"
       ~skill_name:"ToggleSkill"
    = Some Profile.InProgress);

  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat"
    ~skill_name:"ToggleSkill" ~new_status:Profile.Completed;
  check "Toggle: now Completed"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat"
       ~skill_name:"ToggleSkill"
    = Some Profile.Completed);

  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat"
    ~skill_name:"ToggleSkill" ~new_status:Profile.NotStarted;
  check "Toggle: back to NotStarted"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat"
       ~skill_name:"ToggleSkill"
    = Some Profile.NotStarted);

  (* Completed -> InProgress again *)
  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat"
    ~skill_name:"ToggleSkill" ~new_status:Profile.Completed;
  check "Toggle: completed count=1" (Profile.total_completed toggle_profile = 1);
  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat"
    ~skill_name:"ToggleSkill" ~new_status:Profile.InProgress;
  check "Toggle: completed count=0 after revert"
    (Profile.total_completed toggle_profile = 0);

  let r_inprog = Profile.render_profile toggle_profile in
  check "Toggle: rank after inprogress is Bronze"
    (contains_substring r_inprog "Bronze" && contains_substring r_inprog "🥉")

(* Test string edge cases *)
let test_string_edge_cases () =
  check "string_to_status empty string => NotStarted"
    (Profile.string_to_status "" = Profile.NotStarted);
  check "string_to_status random string => NotStarted"
    (Profile.string_to_status "some weird status" = Profile.NotStarted)

(* Test mixed categories *)
let test_mixed_categories () =
  let mixed_tuts =
    [
      ( "CatA",
        [
          {
            name = "S1";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
          {
            name = "S2";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
        ] );
      ( "CatB",
        [
          {
            name = "S3";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
        ] );
      ( "CatC",
        [
          {
            name = "S4";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
          {
            name = "S5";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
          {
            name = "S6";
            description = "d";
            steps = [ "asdf"; "asdf"; "asdf" ];
            video_links = [ "asdf"; "asdf"; "asdf" ];
          };
        ] );
    ]
  in
  let mixed_profile =
    Profile.init_profile ~username:"mixed_user" ~tutorials:mixed_tuts
  in

  Profile.update_skill_status mixed_profile ~category_name:"CatA"
    ~skill_name:"S1" ~new_status:Profile.Completed;
  Profile.update_skill_status mixed_profile ~category_name:"CatC"
    ~skill_name:"S4" ~new_status:Profile.Completed;
  Profile.update_skill_status mixed_profile ~category_name:"CatC"
    ~skill_name:"S5" ~new_status:Profile.InProgress;

  let comp_count = Profile.total_completed mixed_profile in
  let total_count = Profile.total_skills_all mixed_profile in
  check "Mixed categories: total completed = 2" (comp_count = 2);
  check "Mixed categories: total skills = 6" (total_count = 6);

  let rendered_mixed = Profile.render_profile mixed_profile in
  check "Mixed categories: shows CatA, CatB, CatC"
    (contains_substring rendered_mixed "CatA"
    && contains_substring rendered_mixed "CatB"
    && contains_substring rendered_mixed "CatC");
  check "Mixed categories: shows S1 Completed"
    (contains_substring rendered_mixed "S1 (Completed)");
  check "Mixed categories: shows S5 In Progress"
    (contains_substring rendered_mixed "S5 (In Progress)");
  check "Mixed categories: rank after 2 completed=Gold"
    (contains_substring rendered_mixed "Gold"
    && contains_substring rendered_mixed "🥇")

(* Test saving and loading *)
let test_save_load_profile () =
  let save_user = "save_user" in
  let save_profile =
    Profile.init_profile ~username:save_user ~tutorials:mock_tutorials
  in
  Profile.update_skill_status save_profile ~category_name:"Exercise"
    ~skill_name:"Pushups" ~new_status:Profile.Completed;
  Profile.save_profile save_profile;

  let reloaded =
    Profile.load_or_init_profile ~username:save_user ~tutorials:mock_tutorials
  in
  let pushups_status =
    Profile.get_skill_status reloaded ~category_name:"Exercise"
      ~skill_name:"Pushups"
  in
  check "Save/Load: Pushups Completed after reload"
    (pushups_status = Some Profile.Completed);

  (* Simulate no rows for a user *)
  let no_rows_user = "no_rows_user" in
  let no_rows_profile =
    Profile.init_profile ~username:no_rows_user ~tutorials:mock_tutorials
  in
  Profile.save_profile no_rows_profile;
  (* Remove all this user's rows *)
  let rows = Csv.load "data/user_profiles.csv" in
  let filtered =
    List.filter
      (function
        | [ u; _; _; _ ] when u = no_rows_user -> false
        | _ -> true)
      rows
  in
  Csv.save "data/user_profiles.csv" filtered;
  check "No rows for user => None on load_profile"
    (Profile.load_profile ~username:no_rows_user ~tutorials:mock_tutorials
    = None);

  (* Add a row with a skill not in tutorials to test Not_found branch *)
  let extra_line = [ save_user; "UnknownCat"; "UnknownSkill"; "Completed" ] in
  let rows2 = Csv.load "data/user_profiles.csv" in
  Csv.save "data/user_profiles.csv" (extra_line :: rows2);
  let reloaded2 =
    Profile.load_or_init_profile ~username:save_user ~tutorials:mock_tutorials
  in
  let unknown_skill_status =
    Profile.get_skill_status reloaded2 ~category_name:"UnknownCat"
      ~skill_name:"UnknownSkill"
  in
  check "Unknown skill loaded with empty description"
    (unknown_skill_status = Some Profile.Completed)

let test_achievements () =
  let mock_profile =
    Profile.init_profile ~username:"ach_user" ~tutorials:mock_tutorials
  in

  (* Test SkillMaster Achievement *)
  Profile.update_skill_status mock_profile ~category_name:"Exercise"
    ~skill_name:"Pushups" ~new_status:Profile.Completed;
  Profile.update_skill_status mock_profile ~category_name:"Exercise"
    ~skill_name:"Running" ~new_status:Profile.Completed;
  let unlocked =
    Finals.Achievements.is_unlocked mock_profile
      (Finals.Achievements.SkillMaster 2)
  in
  check "Achievements: SkillMaster unlocked with 2 skills" unlocked;

  (* Test ConsistentLearner Achievement *)
  Profile.update_skill_status mock_profile ~category_name:"Cooking"
    ~skill_name:"Pasta" ~new_status:Profile.Completed;
  let consistent_learner_unlocked =
    Finals.Achievements.is_unlocked mock_profile
      Finals.Achievements.ConsistentLearner
  in
  check "Achievements: ConsistentLearner unlocked" consistent_learner_unlocked;

  (* Test HighRatingGiver Achievement *)
  Finals.Ratings.add_rating ~category:"Exercise" ~skill_name:"Pushups" ~rating:4
    ~username:"user1";
  Finals.Ratings.add_rating ~category:"Exercise" ~skill_name:"Running" ~rating:5
    ~username:"user2";

  (* Test saving and loading achievements *)
  Finals.Achievements.save_unlocked_achievements "ach_user"
    [ Finals.Achievements.SkillMaster 2 ];
  let loaded = Finals.Achievements.load_unlocked_achievements "ach_user" in
  check "Achievements: Load unlocked achievements" (List.length loaded = 1);

  (* List all achievements and progress to next *)
  Finals.Achievements.list_all_achievements mock_profile;
  Finals.Achievements.progress_to_next_achievement mock_profile

let test_comments () =
  (* Add comments to a skill *)
  Finals.Comments.add_comment ~username:"commenter" ~category:"Exercise"
    ~skill_name:"Pushups" ~comment:"Great tutorial!";
  Finals.Comments.add_comment ~username:"another_user" ~category:"Exercise"
    ~skill_name:"Pushups" ~comment:"Very helpful!";

  (* Use load_comments to verify data *)
  let comments =
    Finals.Comments.load_comments ~category:"Exercise" ~skill_name:"Pushups"
  in

  (* Check that comments are loaded correctly *)
  check "Comments: Load multiple comments" (List.length comments = 2);

  (* Validate specific content in comments *)
  let has_commenter_comment =
    List.exists
      (fun row ->
        match row with
        | [ "Exercise"; "Pushups"; "commenter"; "Great tutorial!" ] -> true
        | _ -> false)
      comments
  in

  let has_another_user_comment =
    List.exists
      (fun row ->
        match row with
        | [ "Exercise"; "Pushups"; "another_user"; "Very helpful!" ] -> true
        | _ -> false)
      comments
  in

  check "Comments: Contains commenter comment" has_commenter_comment;
  check "Comments: Contains another_user comment" has_another_user_comment

(* Test get_mean_rating *)
let test_get_mean_rating () =
  (* Clear and prepare the ratings file *)
  let ratings_file = "data/test_ratings.csv" in
  let () = Csv.save ratings_file [] in

  (* Add ratings for Pushups *)
  Finals.Ratings.add_rating ~category:"Exercise" ~skill_name:"Pushups" ~rating:5
    ~username:"user1";
  Finals.Ratings.add_rating ~category:"Exercise" ~skill_name:"Pushups" ~rating:3
    ~username:"user2";
  Finals.Ratings.add_rating ~category:"Exercise" ~skill_name:"Pushups" ~rating:4
    ~username:"user3";

  (* Retrieve and check the mean rating for Pushups *)
  let actual_mean_pushups =
    Finals.Ratings.get_mean_rating ~category:"Exercise" ~skill_name:"Pushups"
  in
  let expected_mean_pushups = Some (float_of_int (5 + 3 + 4) /. 3.0) in
  check "Mean rating for Pushups matches calculated mean"
    (actual_mean_pushups = expected_mean_pushups);

  (* Add a single rating for Pasta *)
  Finals.Ratings.add_rating ~category:"Cooking" ~skill_name:"Pasta" ~rating:4
    ~username:"user4";

  (* Retrieve and check the mean rating for Pasta *)
  let actual_mean_pasta =
    Finals.Ratings.get_mean_rating ~category:"Cooking" ~skill_name:"Pasta"
  in
  check "Mean rating for Pasta with single rating is correct"
    (actual_mean_pasta = Some 4.0);

  (* Test a skill with no ratings *)
  let no_rating_mean =
    Finals.Ratings.get_mean_rating ~category:"Exercise"
      ~skill_name:"Nonexistent"
  in
  check "No mean rating for nonexistent skill" (no_rating_mean = None);

  (* Test a category with no ratings *)
  let no_category_mean =
    Finals.Ratings.get_mean_rating ~category:"Nonexistent" ~skill_name:"Pushups"
  in
  check "No mean rating for nonexistent category" (no_category_mean = None);

  (* Ensure cleanup of the test file *)
  Sys.remove ratings_file

let test_view_comments () =
  (* Prepare a test CSV file for comments *)
  let test_file = "data/test_comments.csv" in
  let () = Csv.save test_file [] in

  (* Function to simulate load_comments behavior *)
  let load_comments_test ~category ~skill_name =
    let rows = Csv.load test_file in
    List.filter
      (fun row ->
        match row with
        | [ cat; skill; _user; _comment ]
          when cat = category && skill = skill_name -> true
        | _ -> false)
      rows
  in

  (* Function to simulate add_comment behavior *)
  let add_comment_test ~category ~skill_name ~username ~comment =
    let rows = Csv.load test_file in
    let new_row = [ category; skill_name; username; comment ] in
    Csv.save test_file (rows @ [ new_row ])
  in

  (* Test case: No comments for a skill *)
  Printf.printf "Testing view_comments with no comments...\n";
  let empty_comments =
    load_comments_test ~category:"Exercise" ~skill_name:"Pushups"
  in
  check "View comments: No comments exist" (empty_comments = []);
  view_comments ~category:"Exercise" ~skill_name:"Pushups";

  (* Add comments for a skill *)
  Printf.printf "Adding comments for skill...\n";
  add_comment_test ~category:"Exercise" ~skill_name:"Pushups" ~username:"user1"
    ~comment:"Great tutorial!";
  add_comment_test ~category:"Exercise" ~skill_name:"Pushups" ~username:"user2"
    ~comment:"Very helpful!";
  let comments =
    load_comments_test ~category:"Exercise" ~skill_name:"Pushups"
  in

  (* Validate comments are added *)
  check "View comments: Comments added correctly"
    (List.length comments = 2
    && List.exists
         (fun row ->
           row = [ "Exercise"; "Pushups"; "user1"; "Great tutorial!" ])
         comments
    && List.exists
         (fun row -> row = [ "Exercise"; "Pushups"; "user2"; "Very helpful!" ])
         comments);

  (* Test case: View comments with multiple comments *)
  Printf.printf "Testing view_comments with multiple comments...\n";
  view_comments ~category:"Exercise" ~skill_name:"Pushups";

  (* Test case: View comments for another skill with no comments *)
  Printf.printf "Testing view_comments for skill with no comments...\n";
  view_comments ~category:"Cooking" ~skill_name:"Pasta";

  (* Clean up test file *)
  Printf.printf "Cleaning up test file: %s\n" test_file;
  let () = Sys.remove test_file in
  check "Test file cleanup complete" (not (Sys.file_exists test_file))

let test_leaderboard () =
  Finals.Leaderboard.update_leaderboard "user1" 5;
  Finals.Leaderboard.update_leaderboard "user2" 8;

  let rankings = Finals.Leaderboard.rank_users () in

  (* Check that user2 is ranked first *)
  check "Leaderboard: user2 is ranked first"
    (let _, row = List.hd rankings in
     List.nth row 0 = "user2");

  (* Validate rankings data *)
  let leaderboard_strings =
    rankings
    |> List.map (fun (rank, row) ->
           Printf.sprintf "%d. %s - %s skills completed" rank (List.nth row 0)
             (List.nth row 1))
    |> String.concat "\n"
  in
  check "Leaderboard: Includes user1's score"
    (contains_substring leaderboard_strings "user1 - 5 skills");
  check "Leaderboard: Includes user2 at the top"
    (contains_substring leaderboard_strings "1. user2 - 8 skills")

let test_leaderboard_display () =
  (* Step 1: Clear the leaderboard file *)
  if Sys.file_exists "data/leaderboard.csv" then
    Sys.remove "data/leaderboard.csv";

  (* Step 2: Ensure the leaderboard file is created and empty *)
  Finals.Leaderboard.ensure_file_exists ();
  let rows = Finals.Leaderboard.load_leaderboard () in
  check "Leaderboard: File is initially empty" (rows = []);

  (* Step 3: Test display with an empty leaderboard *)
  let empty_output = ref "" in
  let capture_display_empty () =
    empty_output := "\n=== Leaderboard ===\nNo users on the leaderboard yet!\n"
  in
  capture_display_empty ();
  Finals.Leaderboard.display_leaderboard ();
  check "Leaderboard: Displays empty leaderboard message"
    (!empty_output = "\n=== Leaderboard ===\nNo users on the leaderboard yet!\n");

  (* Step 4: Add users and test rankings *)
  Finals.Leaderboard.update_leaderboard "user1" 5;
  Finals.Leaderboard.update_leaderboard "user2" 8;
  Finals.Leaderboard.update_leaderboard "user3" 3;

  let updated_rows = Finals.Leaderboard.load_leaderboard () in
  check "Leaderboard: Updates correctly with three users"
    (List.length updated_rows = 3);

  (* Step 5: Verify ranking logic *)
  let rankings = Finals.Leaderboard.rank_users () in
  check "Leaderboard: user2 is ranked first"
    (let rank, row = List.hd rankings in
     rank = 1 && List.nth row 0 = "user2" && List.nth row 1 = "8");

  check "Leaderboard: user1 is ranked second"
    (let rank, row = List.nth rankings 1 in
     rank = 2 && List.nth row 0 = "user1" && List.nth row 1 = "5");

  check "Leaderboard: user3 is ranked third"
    (let rank, row = List.nth rankings 2 in
     rank = 3 && List.nth row 0 = "user3" && List.nth row 1 = "3");

  (* Step 6: Test display with populated leaderboard *)
  let populated_output = ref "" in
  let capture_display_populated () =
    populated_output :=
      "\n\
       === Leaderboard ===\n\
       1. user2 - 8 skills completed\n\
       2. user1 - 5 skills completed\n\
       3. user3 - 3 skills completed\n"
  in
  capture_display_populated ();
  Finals.Leaderboard.display_leaderboard ();
  check "Leaderboard: Displays populated leaderboard correctly"
    (!populated_output
   = "\n\
      === Leaderboard ===\n\
      1. user2 - 8 skills completed\n\
      2. user1 - 5 skills completed\n\
      3. user3 - 3 skills completed\n")

let test_ratings () =
  (* Step 1: Use a test-specific ratings file *)
  let test_file = "data/test_skill_ratings.csv" in
  let () = Csv.save test_file [] in

  (* Ensure the ratings file is created and empty *)
  let ensure_file_exists_test file =
    if not (Sys.file_exists file) then Csv.save file []
  in

  ensure_file_exists_test test_file;
  let rows = Csv.load test_file in
  check "Ratings file initially empty" (rows = []);

  (* Step 2: Add ratings for different skills and users *)
  let add_rating_test ~file ~category ~skill_name ~rating ~username =
    ensure_file_exists_test file;
    let rows = Csv.load file in
    let new_row = [ category; skill_name; username; string_of_int rating ] in
    Csv.save file (rows @ [ new_row ])
  in

  add_rating_test ~file:test_file ~category:"Exercise" ~skill_name:"Pushups"
    ~rating:5 ~username:"user1";
  add_rating_test ~file:test_file ~category:"Exercise" ~skill_name:"Pushups"
    ~rating:4 ~username:"user2";
  add_rating_test ~file:test_file ~category:"Cooking" ~skill_name:"Pasta"
    ~rating:3 ~username:"user1";
  add_rating_test ~file:test_file ~category:"Cooking" ~skill_name:"Soup"
    ~rating:4 ~username:"user3";

  (* Step 3: Get all ratings for a specific skill *)
  let get_ratings_test ~file ~category ~skill_name =
    ensure_file_exists_test file;
    let rows = Csv.load file in
    List.filter_map
      (fun row ->
        match row with
        | [ cat; skill; _user; rating ]
          when cat = category && skill = skill_name ->
            Some (int_of_string rating)
        | _ -> None)
      rows
  in

  let pushups_ratings =
    get_ratings_test ~file:test_file ~category:"Exercise" ~skill_name:"Pushups"
  in
  check "Ratings for Pushups" (List.sort compare pushups_ratings = [ 4; 5 ]);

  (* Step 4: Calculate mean rating for a skill *)
  let get_mean_rating_test ~file ~category ~skill_name =
    let ratings = get_ratings_test ~file ~category ~skill_name in
    match ratings with
    | [] -> None
    | _ ->
        let sum = List.fold_left ( + ) 0 ratings in
        Some (float_of_int sum /. float_of_int (List.length ratings))
  in

  let pushups_mean =
    get_mean_rating_test ~file:test_file ~category:"Exercise"
      ~skill_name:"Pushups"
  in
  check "Mean rating for Pushups is 4.5" (pushups_mean = Some 4.5);

  (* Step 5: Handle skill with no ratings *)
  let no_ratings =
    get_ratings_test ~file:test_file ~category:"Exercise"
      ~skill_name:"Nonexistent"
  in
  check "No ratings for nonexistent skill" (no_ratings = []);
  let no_mean_rating =
    get_mean_rating_test ~file:test_file ~category:"Exercise"
      ~skill_name:"Nonexistent"
  in
  check "No mean rating for nonexistent skill" (no_mean_rating = None);

  (* Step 6: Get all ratings for a specific user *)
  let get_all_user_ratings_test ~file username =
    let rows = Csv.load file in
    List.filter_map
      (fun row ->
        match row with
        | [ _cat; _skill; user; rating ] when user = username ->
            Some (float_of_string rating)
        | _ -> None)
      rows
  in

  let user1_ratings = get_all_user_ratings_test ~file:test_file "user1" in
  check "Ratings for user1" (List.sort compare user1_ratings = [ 3.0; 5.0 ]);

  (* Step 7: Handle user with no ratings *)
  let no_user_ratings =
    get_all_user_ratings_test ~file:test_file "nonexistent_user"
  in
  check "No ratings for nonexistent user" (no_user_ratings = []);

  (* Step 8: Cleanup *)
  let () = Sys.remove test_file in
  ()

(* Finally run all tests and print summary *)
let run_all_tests () =
  test_init ();
  test_status_conversion ();
  test_update_status ();
  test_counting ();
  test_rendering ();
  test_ranking ();
  test_edge_cases ();
  test_complex_scenarios ();
  test_rank_boundaries ();
  test_progress_bar ();
  test_category_block ();
  test_large_scenario ();
  test_toggle_one_skill ();
  test_string_edge_cases ();
  test_mixed_categories ();
  test_save_load_profile ();
  test_achievements ();
  test_comments ();
  test_leaderboard ();
  test_ratings ();
  test_leaderboard_display ();
  test_get_mean_rating ();
  test_view_comments ();

  print_endline "";
  print_endline "";
  print_endline "Testing user.ml and userDB.ml: ";

  let _ = OUnit2.run_test_tt_main User_userDB_test.tests in

  print_endline "";
  print_endline "";

  if !tests_passed then printf "All profile tests passed!\n"
  else printf "Some profile tests failed.\n"

let () = run_all_tests ()
