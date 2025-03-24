type skill = {
  name : string;
  description : string;
  steps : string list;
  video_links : string list;
}

let tutorials = ref []

let set_tutorials tutorial_data =
  tutorials := tutorial_data

let get_tutorial category skill_name =
  match List.assoc_opt category !tutorials with
  | Some skills -> List.find_opt (fun s -> s.name = skill_name) skills
  | None -> None

let list_skills category =
  match List.assoc_opt category !tutorials with
  | Some skills -> skills
  | None -> []
