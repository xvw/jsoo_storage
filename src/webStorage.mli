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

(** {1 Types} *)

(** Shortcut for [Dom_html.storage Js.t] *)
type t = Dom_html.storage Js.t

(*

(** Shortcut for events *)
type event = storageEvent Js.t

(** An event to be used with [addEventListener] *)
val event:  event Dom.Event.typ

(** An event to be used with [Lwt_js_events] *)
val lwt_js_event: 
  ?use_capture:bool 
  -> Dom_html.window Js.t
  -> event Lwt.t

(** {1 Interfaces} *)

module type STORAGE =
sig 

  type key = string
  type value = string

  (** Event received where an update is performing on the storage *)
  type storageEvent = {
    key: key option
  ; old_value: value option
  ; new_value: value option
  ; url: string
  }

  (** Returns the JavaScript object of the handler *)
  val handler: t


  (** Returns an integer representing the number of data items stored 
      in the Storage object. 
  *)
  val length: unit -> int


  val get: key -> value option
  (** When passed a key name, will return that key's value. *)

  (** When passed a key name and value, will add that key to 
      the storage, or update that key's value if it already exists. 
  *)
  val set: key -> value -> unit

  (** When passed a key name, will remove that key from the storage. *)
  val remove: key -> unit 

  (** When invoked, will empty all keys out of the storage. *)
  val clear: unit -> unit

  (** When passed a number n, this method will return the name of the 
      nth key in the storage. 
  *)
  val key: int -> key option

  (** Get the couple Key/Values with a numeric index *)
  val at: int -> (key * value) option

  (** Returns all of a Storage as an [Hashtbl.t] *)
  val to_hashtbl: unit -> (key, value) Hashtbl.t

  (** [iter (fun key value -> ... )] apply f on each row of the Storage *)
  val iter: (key -> value -> unit) -> unit

  (** [find p] returns the first element of the storage that
      satisfies the predicate [p]. *)
  val find: (key -> value -> bool) -> (key * value) option

  (** [select p] returns all the elements of storage
      that satisfy the predicate [p] in an [Hashtbl.t]. *)
  val select: (key -> value -> bool) -> (key, value) Hashtbl.t

  (** Watch the mutation of a storage *)
  val onchange: ?prefix:string -> (storageEvent -> unit) -> Dom.event_listener_id

  (** Watch if a new value is inserted *)
  val oninsert: ?prefix:string -> (key -> value -> unit) -> Dom.event_listener_id

  (** Watch if a value is removed *)
  val onremove: ?prefix:string -> (key -> unit) -> Dom.event_listener_id

  (** Watch if a value is updated *)
  val onupdate: ?prefix:string -> (key -> value -> unit) -> Dom.event_listener_id

  (** Watch if the storage is clear *)
  val onclear: (unit -> unit) -> Dom.event_listener_id

end


(** {1 Modules} *)

(** Wrapper for the LocalStorage *)
module Local : STORAGE


(** Wrapper for the SessionStorage *)
module Session : STORAGE
*)