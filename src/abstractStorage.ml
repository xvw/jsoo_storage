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

(** Key data *)
module type KEY_STORAGE = 
sig 

  type key
  type value 

  val of_key:    key -> Js.js_string Js.t
  val of_value:  value -> Js.js_string Js.t
  val to_key:    Js.js_string Js.t -> key
  val to_value:  Js.js_string Js.t -> value

end


(** Minimal interface for Storage implementation *)
module type STORAGE_HANDLER = 
sig 
  include KEY_STORAGE
  val storage: Dom_html.storage Js.t Js.optdef
end

(** General API of a Storage *)
module type STORAGE = 
sig 

  include KEY_STORAGE

  val get:        key -> value option
  val set:        key -> value -> unit
  val remove:     key -> unit 
  val clear:      unit -> unit
  val key:        int -> key option
  val length:     unit -> int
  val to_hashtbl: unit -> (key, value) Hashtbl.t

end

(** Functor to build Storage *)
module Make (S : STORAGE_HANDLER) : STORAGE  = 
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

