(* Example of DOMStorage *)


(** Some unsafe functions to help me *)

module Util =
struct 

  exception Failure

  let fail () = raise Failure
  let unopt x = Js.Opt.get x fail

  let qs parent selector =
    parent##querySelector(Js.string selector)
    |> unopt

  let input elt = 
    Dom_html.CoerceTo.input elt
    |> unopt

  let empty_input elt = elt##.value := Js.string ""

  let key_value prefix key value = 
    let k = Js.to_string key##.value in 
    let p = Js.to_string prefix##.value in 
    let v = Js.to_string value##.value in 
    (p ^ k, v)


  let insert handler form =
    let prefix = input (qs form "#prefix") in 
    let key = input (qs form "#key") in 
    let value = input (qs form "#value") in 
    let k, v = key_value prefix key value in
    let _ = handler k v in
    List.map empty_input [prefix; key; value]

end


let save handler form _ _ = 
  let _ = Util.insert handler form in
  Lwt.return_unit



let session_btn = Util.qs Dom_html.document "#in_session"
let local_btn = Util.qs Dom_html.document "#in_local"
let form = Util.qs Dom_html.document "#creator"

let _ = Lwt_js_events.(
  async_loop
    click
    session_btn
    (save WebStorage.Session.set form)
)
let _ = Lwt_js_events.(
  async_loop
    click
    local_btn
    (save WebStorage.Local.set form)
)

    
    

