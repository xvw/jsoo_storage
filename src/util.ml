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


(** Exception raised if the Storage is not allowed *)
exception Not_supported
exception Not_found

(** Map a function on an option *)
let option_map f = function
  | None -> None 
  | Some x -> Some (f x)


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

let event : event Dom.Event.typ = 
  Dom.Event.make "storage"