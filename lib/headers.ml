(*----------------------------------------------------------------------------
 * Copyright (c) 2019, António Nuno Monteiro
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*)

include H2.Headers

(* TODO: Add user-agent if not defined *)
let canonicalize_headers
    ?(is_h2c_upgrade = false) ~body_length ~host ~version headers
  =
  let headers =
    match version with
    | { Versions.HTTP.major = 2; _ } ->
      of_list
        ((":authority", host)
        :: List.map
             (fun (name, value) -> String.lowercase_ascii name, value)
             headers)
    | { major = 1; _ } ->
      let headers =
        if is_h2c_upgrade then
          ("Connection", "Upgrade, HTTP2-Settings")
          :: ("Upgrade", "h2c")
          :: ("HTTP2-Settings", "")
          :: headers
        else
          headers
      in
      add_unless_exists (of_list headers) "Host" host
    | _ ->
      failwith "unsupported version"
  in
  match body_length with
  | `Fixed n ->
    add_unless_exists headers "content-length" (Int64.to_string n)
  | _ ->
    headers
