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

module type TABLE_DEFINITION = 
sig 
  type key 
  type value 
  val name: string 
  val dump_key: key -> string 
  val dump_value: value -> string
  val load_key: string -> key 
  val load_value: string -> value 
  val storage : Dom_html.storage Js.t
end

module type TABLE = AbstractStorage.STORAGE

module Make (T : TABLE_DEFINITION) = 
struct 


end





