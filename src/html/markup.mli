(*
 * Copyright (c) 2016 Thomas Refis <trefis@janestreet.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)



module Html = Tyxml.Html



val keyword : string -> [> Html_types.span ] Html.elt

module Type : sig
  val path :
    [< Html_types.span_content_fun ] Html.elt list ->
      [> Html_types.span ] Html.elt
  val var : string -> [> Html_types.span ] Html.elt
end

val def_div :
  [< Html_types.code_content_fun ] Html.elt list -> [> Html_types.div ] Html.elt

val def_summary :
  [< Html_types.span_content_fun ] Html.elt list ->
    [> Html_types.summary ] Html.elt

val make_def :
  id:_ Model.Paths.Identifier.t ->
  code:([< Html_types.code_content ] Html.elt) list ->
    (Html_types.div_content Html.elt) list

val make_spec :
  id:_ Model.Paths.Identifier.t ->
  ([< Html_types.div_content ] Html.elt) list ->
    (Html_types.div_content Html.elt) list

val arrow : [> Html_types.span ] Html.elt
(** "->" with a non breaking hyphen, styled as a keyword. *)

val label : Model.Lang.TypeExpr.label -> [> `PCDATA ] Html.elt list
(** For optional arguments adds a word joiner between the question mark and the
    label. *)
