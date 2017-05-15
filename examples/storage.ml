(* Example of DOMStorage *)


(** Some unsafe functions to help me *)

let doc = Dom_html.document
let puts x = Firebug.console##log(x)
let alert x = Dom_html.window##alert(Js.string x)

module Util =
struct 

  exception Failure

  let iter_children f node =
    let nodeL = node##.childNodes in
    let len = nodeL##.length in
    for i = 0 to (pred len) do
      Js.Opt.iter (nodeL ## item(i)) f
    done

  let remove_children fnode =
    let rec iter node =
      match Js.Opt.to_option (node##.firstChild) with
      | None -> ()
      | Some child ->
        let _ = node ## removeChild(child) in iter node
  in iter fnode

  let watch_once event args f =
    let%lwt result = event args in
    let _ = f result in
    Lwt.return ()


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

  let td tr text = 
    let t = Dom_html.createTd doc in
    let txt = doc##createTextNode(Js.string text) in 
    let _ = Dom.appendChild t txt in 
    Dom.appendChild tr t


  let td_i tr text = 
    let t = Dom_html.createTd doc in
    let i = Dom_html.createInput doc in 
    let _ = i##.value := (Js.string text) in
    let _ = Dom.appendChild t i in
    let _ = Dom.appendChild tr t in  
    i


  let btn td text klass key = 
    let data = Js.string "data-key" in 
    let b = Dom_html.createButton doc in 
    let t = doc##createTextNode(Js.string text) in 
    let _ = b##.classList##add(Js.string klass) in 
    let _ = b##setAttribute data (Js.string key) in 
    let _ = Dom.appendChild b t in 
    let _ = Dom.appendChild  td b in b



  let create_cells (module S : WebStorage.STORAGE) tbody =
    let hash = S.to_hashtbl () in 
    Hashtbl.iter (fun key value -> 
      let tr = Dom_html.createTr doc in 
      let _ = td tr key in 
      let i = td_i tr value in 
      let action = Dom_html.createTd doc in 
      let up = btn action "update" "update" key in 
      let del = btn action "delete" "delete" key in 
      let _ = Dom.appendChild tr action in
      let _ = Dom.appendChild tbody tr in 
      let _ =
        Lwt_js_events.(
          async_loop
            click 
            up
            (fun _ _ -> 
              let v = i##.value in 
              S.set key (Js.to_string v);
              alert "Updated !";
              Lwt.return_unit
            )
        ) |> ignore
        in 
        Lwt_js_events.(
          async_loop
            click 
            del
            (fun _ _ -> 
              S.remove key;
              Dom.removeChild tbody tr; 
              alert "Deleted !";
              Lwt.return_unit )
        ) |> ignore
    ) hash


  let onload (module S : WebStorage.STORAGE) tbody = 
    watch_once 
      Lwt_js_events.onload 
      () 
      (fun _ -> 
        let _ = remove_children tbody in 
        create_cells (module S) tbody
      )


end


let save handler form _ _ = 
  let _ = alert "Saved !" in
  let _ = Util.insert handler form in
  Lwt.return_unit


let clear t (module S : WebStorage.STORAGE) _ _ =
  let _ = S.clear () in 
  let _ = Util.remove_children t in 
  let _ = alert "Storage is empty !" in 
  Lwt.return_unit


let session_btn = Util.qs doc "#in_session"
let local_btn = Util.qs doc "#in_local"
let form = Util.qs doc "#creator"
let stbody = Util.qs doc "#session-body"
let ltbody = Util.qs doc "#local-body"
let clears = Util.qs doc "#clear-session"
let clearl = Util.qs doc "#clear-local"

let _ = Util.onload (module WebStorage.Session) stbody
let _ = Util.onload (module WebStorage.Local) ltbody

let _ = Lwt_js_events.(async_loop click session_btn (save WebStorage.Session.set form))
let _ = Lwt_js_events.(async_loop click local_btn (save WebStorage.Local.set form))
let _ = Lwt_js_events.(async_loop click clears (clear stbody (module WebStorage.Session)))
let _ = Lwt_js_events.(async_loop click clearl (clear ltbody (module WebStorage.Local)))
