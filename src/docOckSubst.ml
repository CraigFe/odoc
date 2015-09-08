(*
 * Copyright (c) 2014 Leo White <lpw25@cl.cam.ac.uk>
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

open DocOckPaths
open DocOckTypes


class type ['a] t = object
  method root : 'a -> 'a
  inherit ['a] DocOckMaps.paths
  inherit ['a] DocOckMaps.types
end

let signature s sg =
  s#signature sg

let class_signature s csig =
  s#class_signature csig

let datatype s decl =
  s#type_decl_representation decl

let module_ s md =
  s#module_ md

let module_type s mty =
  s#module_type mty

let type_decl s decl =
  s#type_decl decl

let constructor s cstr =
  s#type_decl_constructor cstr

let field s field =
  s#type_decl_field field

let extension s ext =
  s#extension ext

let exception_ s exn =
  s#exception_ exn

let value s v =
  s#value v

let class_ s cl =
  s#class_ cl

let class_type s cty =
  s#class_type cty

let method_ s meth =
  s#method_ meth

let instance_variable s inst =
  s#instance_variable inst

let comment s com =
  s#documentation_comment com

(* TODO either expose more maps or expose argument map directly *)
let identifier_module s id =
  s#identifier_module id

let module_type_expr s expr =
  s#module_type_expr expr

class ['a] rename_signature ~equal (x : 'a Identifier.signature)
        (y : 'a Identifier.signature) = object

  inherit ['a] DocOckMaps.paths as super

  method root x = x

  method identifier_signature id =
    if Identifier.equal ~equal id x then y
    else super#identifier_signature id

  inherit ['a] DocOckMaps.types

end

let rename_signature ~equal x y =
  new rename_signature ~equal x y

class ['a] rename_class_signature ~equal
           (x : 'a Identifier.class_signature)
           (y : 'a Identifier.class_signature) = object

  inherit ['a] DocOckMaps.paths as super

  method root x = x

  method identifier_class_signature id =
    if Identifier.equal ~equal id x then y
    else super#identifier_class_signature id

  inherit ['a] DocOckMaps.types

end

let rename_class_signature ~equal x y =
  new rename_class_signature ~equal x y

class ['a] rename_datatype ~equal (x : 'a Identifier.datatype)
        (y : 'a Identifier.datatype) = object

  inherit ['a] DocOckMaps.paths as super

  method root x = x

  method identifier_datatype id =
    if Identifier.equal ~equal id x then y
    else super#identifier_datatype id

  inherit ['a] DocOckMaps.types

end

let rename_datatype ~equal x y =
  new rename_datatype ~equal x y

type 'a is_path_kind = Witness : [< Path.kind] is_path_kind

(*let module_id_path (type k) (Witness : k is_path_kind)
                   (id : ('a, k) Identifier.t) name =
  let open Path.Resolved in
    (Module(Identifier id, name))*)

class ['a] prefix ~equal id = object (self)

  inherit ['a] DocOckMaps.paths as super

  method root x = x

(*  method private identifier_path : type k. k is_path_kind ->
                                        ('a, k) Identifier.t ->
                                        ('a, k) Path.Resolved.t option =
      fun wit ->
      let matches id' = Identifier.equal ~equal id id' in
      let open Identifier in function
        | Root _ -> None
        | Module(parent, name) ->
            let open Path.Resolved in
                if matches parent then Some (module_id_path wit id name)
                else None
        | Argument _ -> None
        | ModuleType(parent, name) ->
            let open Path.Resolved in
              if matches parent then Some (ModuleType(Identifier id, name))
              else None
        | Type(parent, name) ->
            let open Path.Resolved in
              if matches parent then Some (Type(Identifier id, name))
              else None
        | CoreType _ -> None
        | Class(parent, name) ->
            let open Path.Resolved in
              if matches parent then Some (Class(Identifier id, name))
              else None
        | ClassType(parent, name) ->
            let open Path.Resolved in
              if matches parent then Some (ClassType(Identifier id, name))
              else None*)

  (* OCaml can't type-check this method yet, so we use magic*)
  method path_resolved : type k. ('a, k) Path.Resolved.t ->
                              ('a, k) Path.Resolved.t =
    fun p ->
      let matches id' =
        Identifier.equal ~equal (Identifier.signature_of_module id) id'
      in
      let open Path.Resolved in
        match p with
        | Identifier (Identifier.Module(parent, name)) ->
            if matches parent then Obj.magic (Module(Identifier id, name))
            else super#path_resolved p
        | Identifier (Identifier.ModuleType(parent, name)) ->
            if matches parent then Obj.magic (ModuleType(Identifier id, name))
            else super#path_resolved p
        | Identifier (Identifier.Type(parent, name)) ->
            if matches parent then Obj.magic (Type(Identifier id, name))
            else super#path_resolved p
        | Identifier (Identifier.Class(parent, name)) ->
            if matches parent then Obj.magic (Class(Identifier id, name))
            else super#path_resolved p
        | Identifier (Identifier.ClassType(parent, name)) ->
            if matches parent then Obj.magic (ClassType(Identifier id, name))
            else super#path_resolved p
        | _ -> super#path_resolved p

  method reference_resolved : type k. ('a, k) Reference.Resolved.t ->
                              ('a, k) Reference.Resolved.t =
    fun r ->
      let id = Identifier.signature_of_module id in
      let matches id' =
        Identifier.equal ~equal id id'
      in
      let open Reference.Resolved in
      match r with
      | Identifier (Identifier.Module(parent, name)) ->
          if matches parent then Module(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.ModuleType(parent, name)) ->
          if matches parent then ModuleType(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Type(parent, name)) ->
          if matches parent then Type(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Extension(parent, name)) ->
          if matches parent then Extension(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Exception(parent, name)) ->
          if matches parent then Exception(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Value(parent, name)) ->
          if matches parent then Value(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Class(parent, name)) ->
          if matches parent then Class(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.ClassType(parent, name)) ->
          if matches parent then ClassType(Identifier id, name)
          else super#reference_resolved r
      | Identifier (Identifier.Label(parent, name)) -> begin
          match parent with
          | Identifier.Root _ | Identifier.Argument _
          | Identifier.Module _ | Identifier.ModuleType _ as parent ->
              let id = Identifier.parent_of_signature id in
                if matches parent then Label(Identifier id, name)
                else super#reference_resolved r
          | _ -> super#reference_resolved r
        end
      | _ -> super#reference_resolved r

  inherit ['a] DocOckMaps.types

end

let prefix ~equal id =
  new prefix ~equal id

let make_lookup (type a) ~equal ~hash
                (items : (a Identifier.module_ * a Identifier.module_) list) =
  let module Hash = struct
    type t = a Identifier.module_
    let equal = Identifier.equal ~equal
    let hash = Identifier.hash ~hash
  end in
  let module Tbl = Hashtbl.Make(Hash) in
  let tbl = Tbl.create 13 in
  List.iter (fun (id1, id2) -> Tbl.add tbl id1 id2) items;
    fun id ->
      let open Identifier in
        match Tbl.find tbl id with
        | id -> Some id
        | exception Not_found -> None

class ['a] pack ~equal ~hash
           (items : ('a Identifier.module_
                     * 'a Identifier.module_) list) = object

  val lookup = make_lookup ~equal ~hash items

  method root x = x

  inherit ['a] DocOckMaps.paths as super

  method identifier : type k. ('a, k) Identifier.t -> ('a, k) Identifier.t =
    fun id ->
      let open Identifier in
        match id with
        | Root _ as id -> begin
            match lookup id with
            | Some (Root _ | Module _ | Argument _ as id) -> id
            | None -> super#identifier id
          end
        | Module _ as id -> begin
            match lookup id with
            | Some (Root _ | Module _ | Argument _ as id) -> id
            | None -> super#identifier id
          end
        | Argument _ as id -> begin
            match lookup id with
            | Some (Root _ | Module _ | Argument _ as id) -> id
            | None -> id
          end
        | _ -> super#identifier id

  inherit ['a] DocOckMaps.types

end

let pack ~equal ~hash items =
  new pack ~equal ~hash items
