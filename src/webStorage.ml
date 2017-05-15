(* MIT License
 * 
 * Copyright (c) 2017 Xavier Van de Woestyne
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)


type t = Dom_html.storage Js.t

class type storageEvent = Util.storageEvent

type event = Util.event

let event = Util.event

let lwt_js_event ?use_capture target = 
  Lwt_js_events.make_event 
    event
    ?use_capture 
    target

module StringKV : AbstractStorage.KEY_STORAGE 
  with type key = string and type value = string = 
struct 
  type key  = string
  type value = string
  let of_key = Js.string 
  let of_value = Js.string 
  let to_key = Js.to_string 
  let to_value = Js.to_string
end



module type STORAGE =
sig 
  
  type key = string
  type value = string

  type storageEvent = {
    key: key option
  ; old_value: value option
  ; new_value: value option
  ; url: string
  }

  val handler: t
  val length: unit -> int
  val get: key -> value option
  val set: key -> value -> unit
  val remove: key -> unit 
  val clear: unit -> unit
  val key: int -> key option
  val at: int -> (key * value) option
  val to_hashtbl: unit -> (key, value) Hashtbl.t
  val iter: (key -> value -> unit) -> unit
  val find: (key -> value -> bool) -> (key * value) option
  val select: (key -> value -> bool) -> (key, value) Hashtbl.t
  val onchange: ?prefix:string -> (storageEvent -> unit) -> Dom.event_listener_id
  val oninsert: ?prefix:string -> (key -> value -> unit) -> Dom.event_listener_id
  val onremove: ?prefix:string -> (key -> unit) -> Dom.event_listener_id
  val onupdate: ?prefix:string -> (key -> value -> unit) -> Dom.event_listener_id
  val onclear: (unit -> unit) -> Dom.event_listener_id
end


module Local = AbstractStorage.Make(
  struct 
    include StringKV
    let storage = Dom_html.window##.localStorage
  end
)

module Session = AbstractStorage.Make(
  struct 
    include StringKV
    let storage = Dom_html.window##.sessionStorage
  end
)