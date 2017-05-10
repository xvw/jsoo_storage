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


module type KEY_STORAGE = 
sig 
  type key
  type value 
  val of_key: key -> Js.js_string Js.t
  val of_value: value -> Js.js_string Js.t
  val to_key: Js.js_string Js.t -> key
  val to_value: Js.js_string Js.t -> value
end

module type STORAGE_HANDLER = 
sig 
  include KEY_STORAGE
  val storage: Dom_html.storage Js.t Js.optdef
end


module type STORAGE = 
sig 
  include KEY_STORAGE
  val get: key -> value option
  val set: key -> value -> unit
  val remove: key -> unit 
  val clear: unit -> unit
  val key: int -> key option
  val at: int -> (key * value) option
  val length: unit -> int
  val to_hashtbl: unit -> (key, value) Hashtbl.t
  val iter: (key -> value -> unit) -> unit
  val find: (key -> value -> bool) -> (key * value) option
  val select: (key -> value -> bool) -> (key, value) Hashtbl.t
end


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

  let at i = 
    match key i with 
    | None -> None 
    | Some k -> 
      Util.option_map (fun e -> (k, e)) (get k)

  let iter f = 
    let len = length () in 
    for i = 0 to (pred len) do 
      match at i with 
      | None -> raise Util.Not_found
      | Some (k, v) -> f k v
    done

  let to_hashtbl () = 
    let len = length () in 
    let hash = Hashtbl.create len in 
    let () = iter (Hashtbl.add hash) in 
    hash

  let find f = 
    let len = length () in 
    let rec loop i = 
      if i = len then None 
      else begin 
        match at i with 
        | None -> raise Util.Not_found
        | Some (k, v) -> 
          if f k v then Some (k, v)
          else loop (succ i)
      end
    in loop 0

  let select f = 
    let hash = Hashtbl.create 16 in 
    iter (fun k v -> if f k v then Hashtbl.add hash k v); 
    hash

end


module StringKV : KEY_STORAGE 
  with type key = string and type value = string = 
struct 
  type key  = string
  type value = string
  let of_key = Js.string 
  let of_value = Js.string 
  let to_key = Js.to_string 
  let to_value = Js.to_string
end

