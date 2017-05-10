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

(** Provide functors to build Concrete Storages.
    This module is mainly used to generate specifics storages.
*)

(** Key data *)
module type KEY_STORAGE = 
sig 

  type key
  type value 


  val of_key: key -> Js.js_string Js.t
  (** Converts a key to the internal representation of a key *)

  val of_value: value -> Js.js_string Js.t
  (** Converts a value to the internal representation of a value *)

  val to_key: Js.js_string Js.t -> key
  (** Converts an internal representation of a key into a key *)

  val to_value: Js.js_string Js.t -> value
  (** Converts an internal representation of a value into a value *)

end

(** Basic Key Value storage *)
module StringKV : KEY_STORAGE with 
  type key = string 
  and type value = string = 
struct 

  (** A type to represent a key *)
  type key  = string

  (** A type to represent a value *)
  type value = string

  (** Converts a key to the internal representation of a key *)
  let of_key = Js.string 

  (** Converts a value to the internal representation of a value *)
  let of_value = Js.string 

  (** Converts an internal representation of a key into a key *)
  let to_key = Js.to_string 

  (** Converts an internal representation of a value into a value *)
  let to_value = Js.to_string

end


(** Minimal interface for Storage implementation *)
module type STORAGE_HANDLER = 
sig 

  include KEY_STORAGE

  (** The Dom Storage *)
  val storage: Dom_html.storage Js.t Js.optdef

end

(** General API of a Storage *)
module type STORAGE = 
sig 

  include KEY_STORAGE

  (** When passed a key name, will return that key's value. *)
  val get: key -> value option

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

  (** Returns an integer representing the number of data items stored 
      in the Storage object. 
  *)
  val length: unit -> int

  (** Returns all of a Storage as an [Hashtbl.t] *)
  val to_hashtbl: unit -> (key, value) Hashtbl.t

end

(** Functor to build Storage *)
module Make (S : STORAGE_HANDLER) : STORAGE with 
  type key = S.key 
  and type value = S.value = 
struct

  include S

  let handler = 
    Js.Optdef.case
      storage
      (fun () -> raise Util.Not_supported)
      (fun x -> x)

  let length () = 
    handler##.length

  let get key = 
    handler##getItem(of_key key)
    |> Js.Opt.to_option
    |> Util.option_map to_value

  let set key value = 
    let k = of_key key in
    let v = of_value value in 
    (handler##setItem k v)

  let remove key = 
    handler##removeItem (of_key key)

  let clear () = handler##clear

  let key i = 
    handler##key(i)
    |> Js.Opt.to_option
    |> Util.option_map to_key

  let get_by_id i = 
    match key i with 
    | None -> raise Util.Not_found 
    | Some k -> begin 
        match get k with 
        | Some v -> (k, v)
        | None -> raise Util.Not_found
      end

  let to_hashtbl () = 
    let len = length () in 
    let hash = Hashtbl.create len in 
    for i = 0 to (pred len) do 
      let k, v = get_by_id i in 
      Hashtbl.add hash k v
    done; 
    hash

  
end

