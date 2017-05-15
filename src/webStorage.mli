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

(** WebStorage is a wrapper around the DOMStorage API.
    The binding provides an OCaml API for using DOMStorage. The 
    library is fragmented in two submodules : Session and Local.

    @see <https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API>
    The reference on Mozilla Developer Network
*)

(** {1 Exceptions} *)
exception Not_supported
exception Not_found


(** {1 Events} *)

(** Patch of StorageEvent *)
class type storageEvent = 
object 
  inherit Dom_html.event
  method key : Js.js_string Js.t Js.opt Js.readonly_prop
  method oldValue : Js.js_string Js.t Js.opt Js.readonly_prop
  method keynewValue : Js.js_string Js.t Js.opt Js.readonly_prop
  method url : Js.js_string Js.t Js.readonly_prop
  method storageArea : Dom_html.storage Js.t Js.opt Js.readonly_prop
end

type event = storageEvent Js.t
val event : event Dom.Event.typ

(** {1 Storage} *)

(** Shortcut for [Dom_html.storage Js.t] *)
type t = Dom_html.storage Js.t

(** {1 Interfaces} *)

(** The basic interface of a storage handler *)
module type STORAGE = 
sig 

  type key = string 
  type value = string
  type old_value = string
  type url = string

  type change_state = 
    | Clear
    | Insert of key * value 
    | Remove of key * old_value 
    | Update of key * old_value * value


  val is_supported: unit -> bool
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

  val on_change : 
    ?prefix:string 
    -> (change_state -> url -> unit) 
    -> Dom.event_listener_id

end