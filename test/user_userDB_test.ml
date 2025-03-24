open Finals
open OUnit2

let test_empty_db _ =
  let db = UserDB.empty () in
  assert (UserDB.contains db "borjan" = false);
  assert (UserDB.contains db "bob" = false)

let test_add_users _ =
  let db = UserDB.empty () in
  let u1 = User.create_user "borjan" (UserDB.encrypt "boss") in
  let u2 = User.create_user "julius" (UserDB.encrypt "skiing") in
  UserDB.add_user db u1;
  assert (UserDB.contains db "borjan");
  assert (UserDB.check db "borjan" "boss");
  assert (UserDB.check db "borjan" "notboss" = false);
  UserDB.add_user db u2;
  assert (UserDB.contains db "julius");
  assert (UserDB.check db "julius" "skiing");
  assert (UserDB.check db "julius" "no" = false)

let test_multiple_users _ =
  let db = UserDB.empty () in
  let u3 = User.create_user "1" (UserDB.encrypt "1") in
  let u4 = User.create_user "2" (UserDB.encrypt "2") in
  let u5 = User.create_user "3" (UserDB.encrypt "3") in
  UserDB.add_user db u3;
  assert (UserDB.contains db "1");
  assert (UserDB.check db "1" "1");
  UserDB.add_user db u4;
  assert (UserDB.contains db "2");
  assert (UserDB.check db "2" "2");
  UserDB.add_user db u5;
  assert (UserDB.contains db "3");
  assert (UserDB.check db "3" "3");
  assert (UserDB.contains db "4" = false);
  assert (UserDB.check db "4" "4" = false);
  assert (UserDB.check db "3" "4" = false)

let test_double_add_failure _ =
  let db = UserDB.empty () in
  let u = User.create_user "fail" (UserDB.encrypt "fail") in
  UserDB.add_user db u;
  assert (UserDB.contains db "fail");
  assert (UserDB.check db "fail" "fail");
  assert_raises UserDB.UserExists (fun () -> UserDB.add_user db u)

let test_encryption_decryption _ =
  let p = "p" in
  let e = UserDB.encrypt p in
  let d = UserDB.decrypt e in
  assert (d = p);

  let p2 = "longer than one letter" in
  let e2 = UserDB.encrypt p2 in
  let d2 = UserDB.decrypt e2 in
  assert (d2 = p2);

  let p3 = "not equal" in
  let e3 = UserDB.encrypt p3 in
  assert (e3 <> p3)

let test_load_save _ =
  let db = UserDB.empty () in
  let uA = User.create_user "testuserA" (UserDB.encrypt "testA") in
  let uB = User.create_user "testuserB" (UserDB.encrypt "testB") in
  let uC = User.create_user "testuserC" (UserDB.encrypt "testC") in
  UserDB.add_user db uA;
  UserDB.add_user db uB;
  UserDB.add_user db uC;
  assert (UserDB.contains db "testuserA");
  assert (UserDB.contains db "testuserB");
  assert (UserDB.contains db "testuserC");

  UserDB.save "test_users.csv" db;
  let l = UserDB.load "test_users.csv" in
  assert (UserDB.contains l "testuserA");
  assert (UserDB.contains l "testuserB");
  assert (UserDB.contains l "testuserC");
  assert (UserDB.check l "testuserA" "testA");
  assert (UserDB.check l "testuserB" "testB");
  assert (UserDB.check l "testuserC" "testC")

let test_nonexisting_user _ =
  let db = UserDB.empty () in
  assert (UserDB.contains db "no" = false);
  assert (UserDB.check db "no" "oops" = false)

let test_random_encrypt_decrypt _ =
  let t = [ "   "; "ivtuyiv"; "h h h"; "borjan" ] in
  List.iter
    (fun s ->
      let e = UserDB.encrypt s in
      let d = UserDB.decrypt e in
      assert (d = s))
    t;

  let e = UserDB.encrypt "" in
  let e = UserDB.decrypt e in
  assert (e = "");

  let w = "password123!@#" in
  let ew = UserDB.encrypt w in
  let dw = UserDB.decrypt ew in
  assert (w = dw)

let test_all_users_correct_passwords _ =
  let db = UserDB.empty () in
  let u1 = User.create_user "a" (UserDB.encrypt "") in
  let u2 = User.create_user "b" (UserDB.encrypt "p") in
  let u3 = User.create_user "c" (UserDB.encrypt "   ") in
  let u4 = User.create_user "d" (UserDB.encrypt "12345") in
  let u5 = User.create_user "e" (UserDB.encrypt "&&&&***") in
  let uX = User.create_user "f" (UserDB.encrypt "pass") in
  UserDB.add_user db u1;
  UserDB.add_user db u2;
  UserDB.add_user db u3;
  UserDB.add_user db u4;
  UserDB.add_user db u5;
  UserDB.add_user db uX;
  assert (UserDB.check db "a" "");
  assert (UserDB.check db "b" "p");
  assert (UserDB.check db "c" "   ");
  assert (UserDB.check db "d" "12345");
  assert (UserDB.check db "e" "&&&&***");
  assert (UserDB.check db "f" "pass")

let test_wrong_passwords _ =
  let db = UserDB.empty () in
  let u1 = User.create_user "a" (UserDB.encrypt "dasdsa") in
  let u2 = User.create_user "b" (UserDB.encrypt "") in
  let u3 = User.create_user "c" (UserDB.encrypt "ads das") in
  let u4 = User.create_user "d" (UserDB.encrypt "wrong") in
  let u5 = User.create_user "e" (UserDB.encrypt "!!!") in
  UserDB.add_user db u1;
  UserDB.add_user db u2;
  UserDB.add_user db u3;
  UserDB.add_user db u4;
  UserDB.add_user db u5;
  assert (UserDB.check db "a" "   " = false);
  assert (UserDB.check db "b" " dasnd" = false);
  assert (UserDB.check db "c" "f" = false);
  assert (UserDB.check db "d" "&&&&***" = false);
  assert (UserDB.check db "e" "1234" = false)

let test_large_number_of_users _ =
  let big_db = UserDB.empty () in
  for i = 1 to 500 do
    let us = "user" ^ string_of_int i in
    let p = "pass" ^ string_of_int i in
    let u = User.create_user us (UserDB.encrypt p) in
    UserDB.add_user big_db u
  done;
  for i = 1 to 50 do
    let uname = "user" ^ string_of_int i in
    let upass = "pass" ^ string_of_int i in
    assert (UserDB.contains big_db uname);
    assert (UserDB.check big_db uname upass)
  done

let test_weird_passwords _ =
  let s = "qwertyuiopasdfghjklzxcvbnm" in
  let es = UserDB.encrypt s in
  let ds = UserDB.decrypt es in
  assert (ds = s);

  let m = "AbCdEfGh" in
  let em = UserDB.encrypt m in
  let dm = UserDB.decrypt em in
  assert (m = dm);

  let r = "zzzzyyyyxxxx" in
  let er = UserDB.encrypt r in
  let dr = UserDB.decrypt er in
  assert (dr = r)

let test_boundary_conditions _ =
  let c = "a" in
  let ec = UserDB.encrypt c in
  let dc = UserDB.decrypt ec in
  assert (dc = c);

  let z = "z" in
  let ez = UserDB.encrypt z in
  let dz = UserDB.decrypt ez in
  assert (z = dz);

  let u = "HELLO" in
  let eu = UserDB.encrypt u in
  let du = UserDB.decrypt eu in
  assert (u = du);

  let n = "12345" in
  let en = UserDB.encrypt n in
  let dn = UserDB.decrypt en in
  assert (n = dn);

  let s = "!@#$%" in
  let es = UserDB.encrypt s in
  let ds = UserDB.decrypt es in
  assert (s = ds);

  let m = "Hello123!z" in
  let em = UserDB.encrypt m in
  let dm = UserDB.decrypt em in
  assert (m = dm)

let test_save_load_big_db _ =
  let big_db = UserDB.empty () in
  for i = 1 to 50 do
    let uname = "user" ^ string_of_int i in
    let upass = "pass" ^ string_of_int i in
    UserDB.add_user big_db (User.create_user uname (UserDB.encrypt upass))
  done;
  UserDB.save "big_db.csv" big_db;
  let big_loaded = UserDB.load "big_db.csv" in
  for i = 1 to 50 do
    let uname = "user" ^ string_of_int i in
    let upass = "pass" ^ string_of_int i in
    assert (UserDB.contains big_loaded uname);
    assert (UserDB.check big_loaded uname upass)
  done

let test_empty_db_save_load _ =
  let emp = UserDB.empty () in
  UserDB.save "empty.csv" emp;
  let l = UserDB.load "empty.csv" in
  assert (UserDB.contains l "someone" = false)

let test_alphabet_shifts _ =
  let a = "abcdefghijklmnopqrstuvwxyz" in
  let e = UserDB.encrypt a in
  let d = UserDB.decrypt e in
  assert (d = a);

  let r = "zyxwvutsrqponmlkjihgfedcba" in
  let e = UserDB.encrypt r in
  let d = UserDB.decrypt e in
  assert (d = r)

let test_double_encryption _ =
  let dub = "doublecheck" in
  let dube = UserDB.encrypt dub in
  let dube2 = UserDB.encrypt dube in
  let dubd2 = UserDB.decrypt dube2 in
  let dubd = UserDB.decrypt dubd2 in
  assert (dubd = dub)

let test_case_sensitivity _ =
  let db = UserDB.empty () in
  let u = User.create_user "lower" (UserDB.encrypt "lower") in
  UserDB.add_user db u;
  assert (UserDB.contains db "lower");
  assert (UserDB.contains db "LOWER" = false);
  assert (UserDB.check db "LOWER" "lower" = false);
  assert (UserDB.check db "lower" "LOWER" = false)

let test_bulk_users _ =
  let many_db = UserDB.empty () in
  for i = 1 to 100 do
    let un = "bulk" ^ string_of_int i in
    let pw = "p" ^ string_of_int i in
    let uu = User.create_user un (UserDB.encrypt pw) in
    UserDB.add_user many_db uu
  done;
  for i = 1 to 100 do
    let un = "bulk" ^ string_of_int i in
    let pw = "p" ^ string_of_int i in
    assert (UserDB.check many_db un pw)
  done;
  UserDB.save "many_db.csv" many_db;
  let many_loaded = UserDB.load "many_db.csv" in
  for i = 1 to 100 do
    let un = "bulk" ^ string_of_int i in
    let pw = "p" ^ string_of_int i in
    assert (UserDB.check many_loaded un pw)
  done

let test_non_alpha_chars _ =
  let s = "!!!abcZZZ" in
  let es = UserDB.encrypt s in
  let ds = UserDB.decrypt es in
  assert (s = ds)

let test_empty_user _ =
  let db = UserDB.empty () in
  let e = User.create_user "" (UserDB.encrypt "") in
  UserDB.add_user db e;
  assert (UserDB.contains db "");
  assert (UserDB.check db "" "");
  UserDB.save "empty.csv" db;
  let emp = UserDB.load "empty.csv" in
  assert (UserDB.contains emp "");
  assert (UserDB.check emp "" "")

let tests =
  "test_userdb"
  >::: [
         "test_empty_db" >:: test_empty_db;
         "test_add_users" >:: test_add_users;
         "test_multiple_users" >:: test_multiple_users;
         "test_encryption_decryption" >:: test_encryption_decryption;
         "test_load_save" >:: test_load_save;
         "test_nonexisting_user" >:: test_nonexisting_user;
         "test_random_encrypt_decrypt" >:: test_random_encrypt_decrypt;
         "test_all_users_correct_passwords" >:: test_all_users_correct_passwords;
         "test_wrong_passwords" >:: test_wrong_passwords;
         "test_large_number_of_users" >:: test_large_number_of_users;
         "test_weird_passwords" >:: test_weird_passwords;
         "test_boundary_conditions" >:: test_boundary_conditions;
         "test_save_load_big_db" >:: test_save_load_big_db;
         "test_empty_db_save_load" >:: test_empty_db_save_load;
         "test_alphabet_shifts" >:: test_alphabet_shifts;
         "test_double_encryption" >:: test_double_encryption;
         "test_case_sensitivity" >:: test_case_sensitivity;
         "test_bulk_users" >:: test_bulk_users;
         "test_non_alpha_chars" >:: test_non_alpha_chars;
         "test_empty_user" >:: test_empty_user;
         "test_double_add_failure" >:: test_double_add_failure;
       ]
