exception Failure

let doc = Dom_html.document
let puts x = Firebug.console##log(x)
let fail () = raise Failure
let unopt x = Js.Opt.get x fail

let qs parent selector =
  parent##querySelector(Js.string selector)
  |> unopt


let li ul text = 
  let l = Dom_html.createLi doc in 
  let txt = doc##createTextNode(Js.string text) in 
  let _ = Dom.appendChild l txt in
  Dom.appendChild ul l

let ul = qs doc "#list"

let _ = 
  WebStorage.Local.onchange (
    fun _ -> li ul "An event is tracked"
  )