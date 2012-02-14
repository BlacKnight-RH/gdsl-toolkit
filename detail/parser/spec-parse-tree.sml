
(* Types used in the AST variant for parsing *)
structure ParseTreeTypes : AST_CORE = struct
   (* a term marked with a source-map span *)
   type 'a mark = 'a Error.mark

   (* qualified names *)
   type 'a path = (Atom.atom list * 'a) Error.mark

   type qid = Atom.atom path
   type ty_bind = Atom.atom
   type ty_use = qid
   type con_bind = Atom.atom
   type con_use = qid
   type var_bind = Atom.atom
   type var_use = qid
   type op_id = Atom.atom
end

(* Parse-tree representation of decoder specifications. *)
structure SpecParseTree = MkAst (ParseTreeTypes)
