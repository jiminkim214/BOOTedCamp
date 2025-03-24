open Printf
open Finals.Tutorial
open Finals.Profile

(* Mock data for testing *)
let mock_tutorials = [
  ("Exercise", [
      {name = "Pushups"; description = "Do 20 pushups."};
      {name = "Running"; description = "Run 5 km."};
    ]);
  ("Cooking", [
      {name = "Pasta"; description = "Cook a pasta dish."};
      {name = "Salad"; description = "Prepare a healthy salad."};
      {name = "Soup"; description = "Make a warm soup."};
    ])
]

let mock_username = "test_user"

(* Instantiate a profile *)
let profile = Profile.init_profile ~username:mock_username ~tutorials:mock_tutorials

(* We will create many tests and run them all in run_all_tests. 
   We'll maintain a global reference to track if any test fails. *)
let tests_passed = ref true

let check test_name condition =
  if not condition then begin
    printf "Test Failed: %s\n" test_name;
    tests_passed := false
  end else
    printf "Test Passed: %s\n" test_name

(* Helper function to check if a substring is present in a string *)
let contains_substring s sub =
  let len_s = String.length s and len_sub = String.length sub in
  let rec aux i =
    if i + len_sub > len_s then false
    else if String.sub s i len_sub = sub then true
    else aux (i+1)
  in
  aux 0

(* Additional helper: Check multiple substrings all present *)
let contains_all_substrings s subs =
  List.for_all (fun sub -> contains_substring s sub) subs

(* Test initialization: All skills should start NotStarted *)
let test_init () =
  let status_ex_pushups = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Pushups" in
  let status_ex_running = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" in
  let status_cook_pasta = Profile.get_skill_status profile ~category_name:"Cooking" ~skill_name:"Pasta" in
  let status_cook_salad = Profile.get_skill_status profile ~category_name:"Cooking" ~skill_name:"Salad" in
  let status_cook_soup = Profile.get_skill_status profile ~category_name:"Cooking" ~skill_name:"Soup" in

  check "Init: Exercise Pushups NotStarted" (status_ex_pushups = Some Profile.NotStarted);
  check "Init: Exercise Running NotStarted" (status_ex_running = Some Profile.NotStarted);
  check "Init: Cooking Pasta NotStarted" (status_cook_pasta = Some Profile.NotStarted);
  check "Init: Cooking Salad NotStarted" (status_cook_salad = Some Profile.NotStarted);
  check "Init: Cooking Soup NotStarted" (status_cook_soup = Some Profile.NotStarted)

(* Test string_to_status and status_to_string conversions *)
let test_status_conversion () =
  check "Status to string: NotStarted" (Profile.status_to_string Profile.NotStarted = "Not Started");
  check "Status to string: InProgress" (Profile.status_to_string Profile.InProgress = "In Progress");
  check "Status to string: Completed" (Profile.status_to_string Profile.Completed = "Completed");

  check "String to status: not started" (Profile.string_to_status "not started" = Profile.NotStarted);
  check "String to status: iN PrOgReSs" (Profile.string_to_status "iN PrOgReSs" = Profile.InProgress);
  check "String to status: COMPLETED" (Profile.string_to_status "COMPLETED" = Profile.Completed);
  check "String to status: unknown defaults to NotStarted" (Profile.string_to_status "foo" = Profile.NotStarted)

(* Test updating skill status and verifying changes *)
let test_update_status () =
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Pushups" ~new_status:Profile.InProgress;
  let new_status = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Pushups" in
  check "Update: Pushups InProgress" (new_status = Some Profile.InProgress);

  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Pasta" ~new_status:Profile.Completed;
  let new_status_pasta = Profile.get_skill_status profile ~category_name:"Cooking" ~skill_name:"Pasta" in
  check "Update: Pasta Completed" (new_status_pasta = Some Profile.Completed);

  (* Non-existent skill *)
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"NonExistent" ~new_status:Profile.Completed;
  let nonexistent_status = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"NonExistent" in
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
  check "Rendering: contains username" (contains_substring rendered mock_username);
  check "Rendering: contains category Exercise" (contains_substring rendered "Category: Exercise");
  check "Rendering: contains category Cooking" (contains_substring rendered "Category: Cooking");
  check "Rendering: has '#' or '-'" ((String.contains rendered '#') || (String.contains rendered '-'))

(* Test ranking logic with incremental updates *)
let test_ranking () =
  (* Reset all to NotStarted *)
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Pushups" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Pasta" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Salad" ~new_status:Profile.NotStarted;
  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Soup" ~new_status:Profile.NotStarted;

  let rendered0 = Profile.render_profile profile in
  check "Ranking: 0 completed = Bronze" (contains_substring rendered0 "Bronze" && contains_substring rendered0 "🥉");

  (* Complete 1 tutorial -> Silver *)
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Pushups" ~new_status:Profile.Completed;
  let rendered1 = Profile.render_profile profile in
  check "Ranking: 1 completed = Silver" (contains_substring rendered1 "Silver" && contains_substring rendered1 "🥈");

  (* 2 completed -> Gold *)
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" ~new_status:Profile.Completed;
  let rendered2 = Profile.render_profile profile in
  check "Ranking: 2 completed = Gold" (contains_substring rendered2 "Gold" && contains_substring rendered2 "🥇");

  (* 3 completed -> Master *)
  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Pasta" ~new_status:Profile.Completed;
  let rendered3 = Profile.render_profile profile in
  check "Ranking: 3 completed = Master" (contains_substring rendered3 "Master" && contains_substring rendered3 "🏆");

  (* 4 completed -> Champion *)
  Profile.update_skill_status profile ~category_name:"Cooking" ~skill_name:"Salad" ~new_status:Profile.Completed;
  let rendered4 = Profile.render_profile profile in
  check "Ranking: 4 completed = Champion" (contains_substring rendered4 "Champion" && contains_substring rendered4 "👑")

(* Edge cases tests *)
let test_edge_cases () =
  (* Non-existent category *)
  let none_status = Profile.get_skill_status profile ~category_name:"NonExistentCat" ~skill_name:"Pushups" in
  check "Edge: Non-existent category returns None" (none_status = None);

  (* Attempt update in non-existent category *)
  Profile.update_skill_status profile ~category_name:"FakeCat" ~skill_name:"Running" ~new_status:Profile.Completed;
  (* Check that this did nothing *)
  let status_running = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" in
  check "Edge: Update in non-existent category does nothing"
    (status_running = Some Profile.Completed);

  (* Multiple updates to the same skill *)
  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" ~new_status:Profile.InProgress;
  let status_running_inprogress = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" in
  check "Edge: Multiple updates - Running InProgress"
    (status_running_inprogress = Some Profile.InProgress);

  Profile.update_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" ~new_status:Profile.NotStarted;
  let status_running_back = Profile.get_skill_status profile ~category_name:"Exercise" ~skill_name:"Running" in
  check "Edge: Multiple updates - Running back to NotStarted"
    (status_running_back = Some Profile.NotStarted);

  (* Check total_completed after toggling statuses *)
  let comp_after_toggle = Profile.total_completed profile in
  (* We had 4 completed but we changed Running back to NotStarted, now we have 3 completed *)
  check "Edge: Total completed after toggling statuses" (comp_after_toggle = 3)

(* Complex scenarios: empty profiles, profiles with empty categories, etc. *)
let test_complex_scenarios () =
  (* Empty tutorials *)
  let empty_tutorials : (string * skill list) list = [] in
  let empty_profile = Profile.init_profile ~username:"empty_user" ~tutorials:empty_tutorials in
  let rendered_empty = Profile.render_profile empty_profile in
  check "Complex: Empty profile render has no categories"
    (not (contains_substring rendered_empty "Category:"));

  (* Ranking on empty profile -> Bronze *)
  let rendered_empty_rank = Profile.render_profile empty_profile in
  check "Complex: Empty profile rank is Bronze"
    (contains_substring rendered_empty_rank "Bronze" && contains_substring rendered_empty_rank "🥉");

  (* Category with no skills *)
  let no_skills_tutorials = [("EmptyCategory", [])] in
  let no_skills_profile = Profile.init_profile ~username:"no_skills_user" ~tutorials:no_skills_tutorials in
  let rendered_no_skills = Profile.render_profile no_skills_profile in
  check "Complex: Category with no skills"
    (contains_substring rendered_no_skills "Category: EmptyCategory" &&
     contains_substring rendered_no_skills "0/0 Completed");

  (* Update non-existent skill in empty category *)
  Profile.update_skill_status no_skills_profile ~category_name:"EmptyCategory" ~skill_name:"GhostSkill" ~new_status:Profile.Completed;
  let rendered_no_skills_after = Profile.render_profile no_skills_profile in
  check "Complex: After updating non-existent skill in empty category"
    (contains_substring rendered_no_skills_after "0/0 Completed");

  (* Single skill category *)
  let single_skill_tuts = [("SingleSkillCat", [{name="Yoga"; description="Do yoga for 10 minutes"}])] in
  let single_skill_profile = Profile.init_profile ~username:"single_skill_user" ~tutorials:single_skill_tuts in
  let rendered_single = Profile.render_profile single_skill_profile in
  check "Complex: Single skill category renders"
    (contains_substring rendered_single "Category: SingleSkillCat" &&
     contains_substring rendered_single "Yoga");

  Profile.update_skill_status single_skill_profile ~category_name:"SingleSkillCat" ~skill_name:"Yoga" ~new_status:Profile.Completed;
  let rendered_single_comp = Profile.render_profile single_skill_profile in
  check "Complex: Single skill completed => Silver rank"
    (contains_substring rendered_single_comp "Silver" && contains_substring rendered_single_comp "🥈")

(* Additional and more fine-grained tests *)

(* Test get_rank_and_emoji directly for all thresholds *)
let test_rank_boundaries () =
  let (r0,e0) = Profile.get_rank_and_emoji 0 in
  check "Rank boundary: 0 completed = Bronze" (r0="Bronze" && e0="🥉");

  let (r1,e1) = Profile.get_rank_and_emoji 1 in
  check "Rank boundary: 1 completed = Silver" (r1="Silver" && e1="🥈");

  let (r2,e2) = Profile.get_rank_and_emoji 2 in
  check "Rank boundary: 2 completed = Gold" (r2="Gold" && e2="🥇");

  let (r3,e3) = Profile.get_rank_and_emoji 3 in
  check "Rank boundary: 3 completed = Master" (r3="Master" && e3="🏆");

  let (r4,e4) = Profile.get_rank_and_emoji 4 in
  check "Rank boundary: 4 completed = Champion" (r4="Champion" && e4="👑");

  let (r10,e10) = Profile.get_rank_and_emoji 10 in
  check "Rank boundary: 10 completed still Champion"
    (r10="Champion" && e10="👑")

(* Test intermediate rendering functions indirectly via full render:
   Already done, but let's test explicitly progress bars with custom data *)

let test_progress_bar () =
  (* Create a custom category_progress for testing *)
  let cat_progress = {
    Profile.category_name = "TestCat";
    skills = [
      {skill_name="A"; description=""; status=Profile.Completed};
      {skill_name="B"; description=""; status=Profile.InProgress};
      {skill_name="C"; description=""; status=Profile.NotStarted};
      {skill_name="D"; description=""; status=Profile.Completed};
    ]
  } in
  let bar = Profile.render_progress_bar cat_progress in
  (* 4 skills total, 2 completed => 2/4 = 0.5, half of 20 chars => 10 '#'s *)
  check "Progress bar: 2/4 completed should show 10 '#'"
    (contains_substring bar "##########" && contains_substring bar "10/20 Completed" = false);

  (* Wait, the bar shows `x/y Completed` where x is number completed and y is total.
     Actually, it prints something like "[##########----------] 2/4 Completed"
  *)
  check "Progress bar: correct count in string"
    (contains_substring bar "2/4 Completed");
  (* Ensure both '#' and '-' are present *)
  check "Progress bar: shows correct ratio"
    (contains_substring bar "[" && contains_substring bar "]" &&
     contains_substring bar "#" && contains_substring bar "-")

(* Test rendering a category block *)
let test_category_block () =
  let cat_progress = {
    Profile.category_name = "TestCategory";
    skills = [
      {skill_name="Skill1"; description="Desc1"; status=Profile.Completed};
      {skill_name="Skill2"; description="Desc2"; status=Profile.NotStarted};
    ]
  } in
  let block = Profile.render_category_block cat_progress in
  check "Category block: contains category name" (contains_substring block "Category: TestCategory");
  check "Category block: contains Skill1 with Completed" (contains_substring block "Skill1 (Completed)");
  check "Category block: contains Skill2 with Not Started" (contains_substring block "Skill2 (Not Started)");

  (* Check progress bar inside block *)
  check "Category block: progress bar 1/2 completed"
    (contains_substring block "1/2 Completed")

(* Test large scenario: Many categories and skills *)
let test_large_scenario () =
  let big_tutorials =
    let rec make_skills n =
      if n = 0 then [] else {name= "Skill"^(string_of_int n); description="D"} :: make_skills (n-1)
    in
    [
      ("BigCat1", make_skills 10);
      ("BigCat2", make_skills 15);
      ("BigCat3", make_skills 5);
    ]
  in
  let big_profile = Profile.init_profile ~username:"big_user" ~tutorials:big_tutorials in
  (* Initially all NotStarted *)
  check "Large scenario: total skills = 30" (Profile.total_skills_all big_profile = 30);
  check "Large scenario: total completed = 0" (Profile.total_completed big_profile = 0);

  (* Complete all in BigCat1 *)
  List.iter (fun i ->
    Profile.update_skill_status big_profile ~category_name:"BigCat1"
      ~skill_name:("Skill"^(string_of_int i)) ~new_status:Profile.Completed) (List.init 10 (fun x->x+1));

  check "Large scenario: after completing BigCat1 (10 skills), completed=10"
    (Profile.total_completed big_profile = 10);

  (* InProgress some in BigCat2 *)
  List.iter (fun i ->
    if i mod 2 = 0 then
      Profile.update_skill_status big_profile ~category_name:"BigCat2"
        ~skill_name:("Skill"^(string_of_int i)) ~new_status:Profile.InProgress) (List.init 15 (fun x->x+1));

  (* Check no error in rendering large profile *)
  let rendered_large = Profile.render_profile big_profile in
  check "Large scenario: renders large profile without crashing"
    (contains_substring rendered_large "Category: BigCat1" &&
     contains_substring rendered_large "Category: BigCat2" &&
     contains_substring rendered_large "Category: BigCat3");

  (* Check rank after 10 completed is still Champion (since >4) *)
  check "Large scenario: rank after 10 completed = Champion"
    (contains_substring rendered_large "Champion" && contains_substring rendered_large "👑")

(* Test toggling statuses extensively for one skill *)
let test_toggle_one_skill () =
  let toggle_profile = Profile.init_profile ~username:"toggle_user" ~tutorials:[("ToggleCat", [{name="ToggleSkill"; description="X"}])] in
  check "Toggle: initially NotStarted"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" = Some Profile.NotStarted);
  
  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" ~new_status:Profile.InProgress;
  check "Toggle: now InProgress"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" = Some Profile.InProgress);

  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" ~new_status:Profile.Completed;
  check "Toggle: now Completed"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" = Some Profile.Completed);

  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" ~new_status:Profile.NotStarted;
  check "Toggle: back to NotStarted"
    (Profile.get_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" = Some Profile.NotStarted);

  (* Confirm total_completed goes up and down as we toggle *)
  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" ~new_status:Profile.Completed;
  check "Toggle: completed count=1 after completed"
    (Profile.total_completed toggle_profile = 1);
  Profile.update_skill_status toggle_profile ~category_name:"ToggleCat" ~skill_name:"ToggleSkill" ~new_status:Profile.InProgress;
  check "Toggle: completed count=0 after removing completed"
    (Profile.total_completed toggle_profile = 0);
  
  (* Check rank toggling *)
  let r_inprog = Profile.render_profile toggle_profile in
  check "Toggle: rank after inprogress is Bronze"
    (contains_substring r_inprog "Bronze" && contains_substring r_inprog "🥉")

(* Test string edge cases for string_to_status *)
let test_string_edge_cases () =
  check "string_to_status empty string => NotStarted" (Profile.string_to_status "" = Profile.NotStarted);
  check "string_to_status random string => NotStarted" (Profile.string_to_status "some weird status" = Profile.NotStarted)

(* Test multiple categories with mixed statuses *)
let test_mixed_categories () =
  let mixed_tuts = [
    ("CatA", [{name="S1"; description="d"}; {name="S2"; description="d"}]);
    ("CatB", [{name="S3"; description="d"}]);
    ("CatC", [{name="S4"; description="d"}; {name="S5"; description="d"}; {name="S6"; description="d"}]);
  ] in
  let mixed_profile = Profile.init_profile ~username:"mixed_user" ~tutorials:mixed_tuts in

  (* Complete some skills in CatA and CatC *)
  Profile.update_skill_status mixed_profile ~category_name:"CatA" ~skill_name:"S1" ~new_status:Profile.Completed;
  Profile.update_skill_status mixed_profile ~category_name:"CatC" ~skill_name:"S4" ~new_status:Profile.Completed;
  Profile.update_skill_status mixed_profile ~category_name:"CatC" ~skill_name:"S5" ~new_status:Profile.InProgress;

  let comp_count = Profile.total_completed mixed_profile in
  let total_count = Profile.total_skills_all mixed_profile in
  check "Mixed categories: total completed = 2"
    (comp_count = 2);
  check "Mixed categories: total skills = 6"
    (total_count = 6);

  (* Rendering and checking presence *)
  let rendered_mixed = Profile.render_profile mixed_profile in
  check "Mixed categories: shows CatA, CatB, CatC"
    (contains_substring rendered_mixed "CatA" && contains_substring rendered_mixed "CatB" && contains_substring rendered_mixed "CatC");

  (* Check that completed and in-progress are shown correctly *)
  check "Mixed categories: shows S1 Completed"
    (contains_substring rendered_mixed "S1 (Completed)");
  check "Mixed categories: shows S5 In Progress"
    (contains_substring rendered_mixed "S5 (In Progress)");

  (* Check rank after 2 completed = Gold *)
  check "Mixed categories: rank after 2 completed=Gold"
    (contains_substring rendered_mixed "Gold" && contains_substring rendered_mixed "🥇")

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

  if !tests_passed then
    printf "All profile tests passed!\n"
  else
    printf "Some profile tests failed.\n"

let () = run_all_tests ()