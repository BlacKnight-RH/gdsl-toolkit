structure Environment : sig
   type environment

   structure SpanMap : ORD_MAP where type Key.ord_key = Error.span

   structure SymbolSet : ORD_SET where type Key.ord_key = SymbolTable.symid
   
   val primitiveEnvironment : (SymbolTable.symid *
                               Types.texp *
                               (BooleanDomain.bfun -> BooleanDomain.bfun) *
                               (Types.texp option)) list *
                               SizeConstraint.size_constraint list ->
                               environment
   
   val pushSingle : VarInfo.symid * Types.texp * environment -> environment
   
   (*add a group of bindings to the current environment, each element in a
   binding is identified by its symbol, the flag is true if the symbol
   is a decoder function*)
   val pushGroup : (VarInfo.symid * bool) list * environment ->
                  environment
   (*remove a binding group from the stack; the flag is true if the outermost
   scope should be kept, the result is a list of error messages about
   ambiguous type variables*)
   val popGroup : environment * bool ->
                  (Error.span * string) list * environment
   
   (*ask for all the symbols in the binding group*)
   val getGroupSyms : environment -> VarInfo.symid list
   
   val pushTop : environment -> environment
   
   (*pushes the given type onto the stack, if the flag is true, type variables
   are renamed*)
   val pushType : bool * Types.texp * environment -> environment

   val pushMonadType : Types.texp * environment -> environment
   
   (* push the width of a decode onto the stack*)
   val pushWidth : VarInfo.symid * environment -> environment

   (* For a function from a type containing several type variables to an
   algoebraic data type, generate implications from the arguments of the
   algebraic data type to the argument of this function. *)
   val genConstructorFlow : (bool * environment) -> environment
   
    (*given an occurrence of a symbol at a position, push its type onto the
    stack; arguments are the symbol to look up, the position it occurred and a
    Boolean flag indicating if this usage should be recorded (True) or if an
    existing type should be used (False), and a flag that indicates if
    a fresh instance or the plain type should be pushed *)
   val pushSymbol : VarInfo.symid * Error.span * bool * bool * environment -> environment

   (*search in the current stack for the symbol and, if unsuccessful, in the
   nested definitions and push all nested groups onto the stack, returns the
   new stack and the number of nested groups that had to be pushed*)
   val pushNested : VarInfo.symid * environment -> (int * environment)

   (*pops the nested groups that were pushed by pushNested*)
   val popNested : int * environment -> environment

   val getUsages : VarInfo.symid * environment -> Error.span list
   
   val getContextOfUsage : VarInfo.symid * Error.span * environment ->
                           VarInfo.symid

   val getCtxt : environment -> VarInfo.symid list

      (*stack: [...,t] -> [...] and type of f for call-site s is set to t*)
   val popToUsage : VarInfo.symid * Error.span * environment -> environment

   (*stack: [...] -> [...,t] where t is type of usage of f at call-site s*)
   val pushUsage : VarInfo.symid * Error.span * environment -> environment
   
   (*stack: [...] -> [..., x:a], 'a' fresh; primed version also returns 'a'*)
   val pushLambdaVar' : VarInfo.symid * environment -> (Types.texp * environment)
   val pushLambdaVar : VarInfo.symid * environment -> environment
   
   (*stack: [..., t0, t1, ... tn] -> [..., {f1:t1, ... fn:tn, t0:...}]*)
   val reduceToRecord : (BooleanDomain.bvar * FieldInfo.symid) list *
                        environment -> environment

   (*stack: [..., tn, ..., t2, t1, t0] -> [..., SUM (tn,..t0)]*)
   val reduceToSum : int * environment -> environment
   
   (*stack: [...,t1,t2,...,tn] -> [...,(t1, ... t n-1) -> tn]*)
   val reduceToFunction : environment * int -> environment
   
   (*stack: [...,t1 -> t2] -> [...t2]*)
   val reduceToResult : environment -> environment

   (*stack: [...,t1 -> t2] -> [...t1]*)
   val reduceToArgument : environment -> environment

   (*stack: [..., tn, ..., t2, t1, t0] -> [..., t0]*)
   val return : int * environment -> environment

   val popKappa : environment -> environment

   (*stack: [..., t2, t1], meet t1=t2 for types and flow *)
   val equateKappas : environment -> environment

   (*stack: [..., t2, t1], meet t1=t2 for types and t2=>t1 for flow*)
   val equateKappasFlow : environment -> environment

   (*stack: [..., t2, t1] -> [..., t1, t2] *)
   val flipKappas : environment -> environment

   (*stack: [..., t1, t2], compute mgu(t1,t2) and return the set
     of substitutions for t1; this set is empty if t1 is smaller
     (more specific) than t2; when testing for stability t1 is
     the usage site and t2 the fresh function instance *)
   val subsetKappas : environment -> Substitutions.Substs

   (*stack: [...,t] -> [...] and type of function f is set to t*)
   val popToFunction : VarInfo.symid * environment -> environment

   (*push the name of the function into the current context (the context
   determines in which function calls to unknown functions are recorded)*)
   val enterFunction : VarInfo.symid * environment -> environment

   (*pop the last function from the current context*)
   val leaveFunction : VarInfo.symid * environment -> environment
   
   (*unset the type of function f if possible; if the function type was set,
   return an environment in which the function type was pushed, otherwise
   return nothing*)
   val clearFunction : VarInfo.symid * environment -> environment option
   
   val forceNoInputs : VarInfo.symid * VarInfo.symid list *
                     environment -> VarInfo.symid list

    (*apply the Boolean function*)
   val meetBoolean : (BooleanDomain.bfun -> BooleanDomain.bfun) *
         environment -> environment

   val reduceFlow :  environment -> environment

   val meetSizeConstraint : (SizeConstraint.size_constraint_set ->
                             SizeConstraint.size_constraint_set) *
                             environment -> environment

   (*query all function symbols in binding groups that would be modified by
   the given substitutions*)
   val affectedFunctions : Substitutions.Substs * environment -> SymbolSet.set

   val toString : environment -> string
   val toStringSI : environment * TVar.varmap -> string * TVar.varmap
   val topToString : environment -> string
   val topToStringSI : environment * TVar.varmap -> string * TVar.varmap
   val kappaToString : environment -> string
   val kappaToStringSI : environment * TVar.varmap -> string * TVar.varmap
   val funTypeToStringSI  : environment * VarInfo.symid * TVar.varmap ->
                            string * TVar.varmap
end = struct
   structure ST = SymbolTable
   structure BD = BooleanDomain
   structure SC = SizeConstraint
   structure SpanMap = SpanMap
   open Types
   open Substitutions
   
   (*restrict which symbols toString prints*)
   val debugSymbol : int option = NONE

   (*any error that is not due to unification*)
   exception InferenceBug
   
   datatype binding
      = KAPPA of {
         ty : texp
      } | SINGLE of {
         name : ST.symid,
         ty : texp
      } | GROUP of {
         name : ST.symid,
         (*the type of this function, NONE if not yet known*)
         ty : (texp * BD.bfun) option,
         (*this is SOME (CONST w) if this is a decode function with pattern width w*)
         width : texp option,
         uses : (ST.symid * texp) SpanMap.map,
         (*a tree of nested binding groups*)
         nested : binding list
      } list
   
   datatype bind_info
      = SIMPLE of { ty : texp }
      | COMPOUND of { ty : (texp * BD.bfun) option, width : texp option,
                      uses : (ST.symid * texp) SpanMap.map,
                      nested : binding list }

   (*a scope contains one of the bindings above and some additional
   information that make substitution and join cheaper*)
   structure Scope : sig
      type scope
      type constraints
      val getFlow : constraints -> BooleanDomain.bfun
      val setFlow : BooleanDomain.bfun -> constraints -> constraints
      val getSize : constraints -> SC.size_constraint_set
      val setSize : SC.size_constraint_set -> constraints -> constraints
      val getCtxt : constraints -> VarInfo.symid list
      val getCurFun : constraints -> VarInfo.symid
      val setCtxt : VarInfo.symid list -> constraints -> constraints

      type environment = scope list * constraints
      val initial : binding * SC.size_constraint_set -> environment
      val wrap : binding * environment -> environment
      val unwrap : environment -> (binding * environment)
      val unwrapDifferent : environment * environment ->
            (binding * binding) option * environment * environment
      val getVars : environment -> TVar.set
      val getBVars : environment -> BD.bvarset
      val getVarsUses : ST.symid * environment -> TVar.set * BD.bvarset
      val getMonoVars : environment -> TVar.set * BD.bvarset
      val lookup : ST.symid * environment -> TVar.set * bind_info
      val update : ST.symid  *
                   (bind_info * constraints -> bind_info * constraints) *
                   environment-> environment
      val toString : scope * TVar.varmap -> string * TVar.varmap
   end = struct
      type scope = {
         bindInfo : binding,
         typeVars : TVar.set,
         boolVars : BD.bvarset,
         version : int
      }
      type constraints = {
         flowInfo : BD.bfun,
         sizeInfo : SC.size_constraint_set,
         context : VarInfo.symid list
      }
      
      fun getFlow { flowInfo = fi, sizeInfo, context } = fi
      fun setFlow fi { flowInfo = _, sizeInfo = si, context = ctxt } =
         { flowInfo = fi, sizeInfo = si, context = ctxt }
      fun getSize { flowInfo, sizeInfo = si, context } = si
      fun setSize si { flowInfo = fi, sizeInfo = _, context = ctxt } =
         { flowInfo = fi, sizeInfo = si, context = ctxt }
      fun getCtxt { flowInfo, sizeInfo, context = ctxt } = ctxt
      fun getCurFun { flowInfo, sizeInfo, context = ctxt } = case ctxt of
           (curFun :: _) => curFun
         | [] => raise InferenceBug
      fun setCtxt ctxt { flowInfo = fi, sizeInfo = si, context = _ } =
         { flowInfo = fi, sizeInfo = si, context = ctxt }

      type environment = scope list * constraints
   
      val verCounter = ref 1
      fun nextVersion () =  let
           val v = !verCounter
         in
           (verCounter := v+1; v)
         end             

      fun prevTVars [] = TVar.empty
        | prevTVars ({bindInfo, typeVars = tv, boolVars, version}::_) = tv

      fun varsOfBinding (KAPPA {ty=t}, set) = texpVarset (t,set)
        | varsOfBinding (SINGLE {name, ty=t}, set) = texpVarset (t,set)
        | varsOfBinding (GROUP bs, set) = let
           fun vsOpt (SOME t,set) = texpVarset (t,set)
             | vsOpt (NONE,set) = set
           fun bvsOpt (SOME (t,_),set) = texpVarset (t,set)
             | bvsOpt (NONE,set) = set
           fun getUsesVars ((ctxt',t),set) = texpVarset (t,set)
           fun getBindVars ({name=n, ty=t, width=w, uses, nested},set) =
               List.foldl getUsesVars
                  (bvsOpt (t, vsOpt (w,set)))
                  (SpanMap.listItems uses)
        in
           List.foldl getBindVars set bs
        end

      fun prevBVars [] = BD.emptySet
        | prevBVars ({bindInfo, typeVars, boolVars = bv, version}::_) = bv

      val texpBVarset = texpBVarset (fn ((_,v),vs) => BD.addToSet (v,vs))

      fun bvarsOfBinding (KAPPA {ty}, ctxt, set) = texpBVarset (ty,set)
        | bvarsOfBinding (SINGLE {name, ty}, ctxt, set) = texpBVarset (ty,set)
        | bvarsOfBinding (GROUP bs, ctxt, set) =
         let
            fun getUsesVars ((site,t),set) =
               if List.exists (fn sym => ST.eq_symid (sym,site)) ctxt then
                  texpBVarset (t,set)
               else
                  set
            fun getBindVars ({name=n, ty=tOpt, width, uses, nested},set) =
               List.foldl getUsesVars
                  (if List.exists (fn sym => ST.eq_symid (sym,n)) ctxt
                   then case tOpt of
                     NONE => set | SOME (t,_) => texpBVarset (t,set)
                   else set)
                  (SpanMap.listItems uses)

         in
            List.foldl getBindVars set bs
         end

      fun getMonoVars (bis,_) = List.foldl
        (fn ({bindInfo = bi, typeVars, boolVars, version},(vSet,bSet)) => 
         case bi of
              KAPPA { ty = t } => (texpVarset (t,vSet), texpBVarset (t,bSet))
            | SINGLE { ty = t,... } => (texpVarset (t,vSet), texpBVarset (t,bSet))
            | GROUP _ => (vSet,bSet))
        (TVar.empty, BD.emptySet) bis

      fun getVarsUses (sym, (scs,_)) =
         let
            fun getUsesVars ((site,t),(vSet,bSet)) =
               if ST.eq_symid (sym,site) then
                  (texpVarset (t,vSet), texpBVarset (t,bSet))
               else
                  (vSet,bSet)
            fun getWidthVars (NONE, set) = set
              | getWidthVars (SOME w, (vSet,bSet)) = (texpVarset (w,vSet),bSet)
            fun getBindVars ({name=n, ty, width = wOpt, uses, nested},set) =
               List.foldl getUsesVars (getWidthVars (wOpt, set))
                  (SpanMap.listItems uses)
            fun getGroupVars ({bindInfo = bi, typeVars, boolVars, version},set) =
               case bi of
                    KAPPA {ty} => set
                  | SINGLE {name, ty} => set
                  | GROUP bs => List.foldl getBindVars set bs
         in
            List.foldl getGroupVars (TVar.empty, BD.emptySet) scs
         end

      fun initial (b, scs) =
         ([{
            bindInfo = b,
            typeVars = varsOfBinding (b, TVar.empty),
            boolVars = BD.emptySet,
            version = 0
          }], {
            flowInfo = BD.empty,
            sizeInfo = scs,
            context = []
          })
      fun wrap (b, (scs, state)) =
         ({
            bindInfo = b,
            typeVars = varsOfBinding (b, prevTVars scs),
            boolVars = bvarsOfBinding (b, getCtxt state, prevBVars scs),
            version = nextVersion ()
         }::scs,state)
      fun unwrap ({bindInfo = bi, typeVars, boolVars, version} :: scs, state) =
            (bi, (scs, state))
        | unwrap ([], state) = raise InferenceBug
      fun unwrapDifferent
            ((all1 as ({bindInfo = bi1, typeVars = _, boolVars = _, version = v1 : int}::scs1,
             cons1))
            ,(all2 as ({bindInfo = bi2, typeVars = _, boolVars = _, version = v2 : int}::scs2,
             cons2))) =
            if v1=v2 then (NONE, all1, all2)
            else (SOME (bi1,bi2),(scs1,cons1),(scs2,cons2))
        | unwrapDifferent (all1 as ([], _), all2 as ([], _)) =
            (NONE, all1, all2)
        | unwrapDifferent (_, _) = raise InferenceBug
      
      fun getVars (scs, state) = prevTVars scs

      fun getBVars (scs, state) = prevBVars scs

      fun lookup (sym, (scs, cons)) =
         let
            fun l [] = (TextIO.print ("urk, tried to lookup non-existent symbol " ^ Int.toString (SymbolTable.toInt sym) ^ ": " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ "\n")
                       ;raise InferenceBug)
              | l ({bindInfo = KAPPA _, typeVars, boolVars, version}::scs) = l scs
              | l ({bindInfo = SINGLE {name, ty}, typeVars, boolVars, version}::scs) =
                  if ST.eq_symid (sym,name) then
                     (prevTVars scs, SIMPLE { ty = ty})
                  else l scs
              | l ({bindInfo = GROUP bs, typeVars, boolVars, version}::scs) =
                  let fun lG other [] = l scs
                        | lG other ((b as {name, ty, width, uses, nested})::bs) =
                           if ST.eq_symid (sym,name) then
                              (prevTVars scs,
                              COMPOUND { ty = ty, width = width, uses = uses, nested = nested })
                           else lG (b :: other) bs
                  in
                     lG [] bs
                  end
      
         in
            l scs
         end

      fun update (sym, action, env) =
         let
            fun tryUpdate (KAPPA _, cons) = NONE
              | tryUpdate (SINGLE {name, ty}, cons) =
                if ST.eq_symid (sym,name) then
                  let
                     val (SIMPLE {ty}, cons) = action (SIMPLE {ty = ty}, cons)
                  in
                     SOME (SINGLE {name = name, ty = ty}, cons)
                  end
                else NONE
              | tryUpdate (GROUP bs, cons) =
               let fun upd (otherBs, []) = NONE
                     | upd (otherBs, (b as {name, ty, width, uses, nested})::bs) =
                        if ST.eq_symid (sym,name) then
                           let val (COMPOUND { ty = ty, width = width,
                                               uses = uses, nested = nested}, cons) =
                                   action (COMPOUND { ty = ty, width = width,
                                                      uses = uses, nested = nested}, cons)
                           in
                              SOME (GROUP (List.revAppend (otherBs,
                                          {name = name, ty = ty,
                                           width = width, uses = uses,
                                           nested = nested} :: bs))
                                   ,cons)
                           end
                        else upd (b::otherBs, bs)
               in
                  upd ([],bs)
               end
            fun unravel (bs, ([],_)) = raise InferenceBug
              | unravel (bs, env) = case unwrap env of
               (b, env as (scs, cons)) =>
                  (case tryUpdate (b, cons) of
                       NONE => unravel (b::bs, env)
                     | SOME (b,cons) => List.foldl wrap (scs, cons) (b::bs) )
         in
            unravel ([], env)
         end

      fun showVarsVer (typeVars,boolVars,ver,si) =
         let
            val (vsStr, si) = TVar.setToString (typeVars,si)
            val bsStr = BD.setToString boolVars
         in
            ("ver=" ^ Int.toString(ver) ^
             ", bvars = " ^ bsStr ^  ", vars=" ^ vsStr ^ "\n", si)
         end

      fun toString ({bindInfo = bi, typeVars, boolVars, version}, si) =
            let
               val (scStr, si) = showVarsVer (typeVars, boolVars, version, si)
               val (biStr, si) = showBindInfoSI (bi,si)
            in
               if String.size biStr=0 then ("",si) else (scStr ^ biStr, si)
            end
      and showBindInfoSI (KAPPA {ty}, si) =
            let
               val (tStr, si) = showTypeSI (ty,si)
            in
               case debugSymbol of
                  (SOME _) => ("",si)
                | NONE => ("KAPPA : " ^ tStr, si)
            end
        | showBindInfoSI (SINGLE {name, ty}, si) =
            let
               val (tStr, si) = showTypeSI (ty,si)
               val visible = case debugSymbol of
                     NONE => true
                   | (SOME sid) => sid=SymbolTable.toInt name
            in
               if visible then
                  ("SYMBOL " ^ ST.getString(!SymbolTables.varTable, name) ^
                  " : " ^ tStr, si)
               else
                  ("",si)
            end
        | showBindInfoSI (GROUP bs, si) =
            let
               fun prTyOpt (NONE, str, si) = ("", si)
                 | prTyOpt (SOME t, str, si) = let
                    val (tStr, si) = showTypeSI (t, si)
                 in
                     (str ^ tStr, si)
                 end
               fun prBTyOpt (NONE, str, si) = ("", si)
                 | prBTyOpt (SOME (t,bFun), str, si) = let
                    val (tStr, si) = showTypeSI (t, si)
                    val bStr = if concisePrint then "" else
                               ", flow:" ^ BD.showBFun bFun
                 in
                     (str ^ tStr ^ bStr, si)
                 end
               fun printU (({span=(p1,p2),file=_}, (ctxt, t)), (str, sep, si)) =
                  let
                     val (tStr, si) = showTypeSI (t, si)
                  in
                     (str ^
                      sep ^ Int.toString(Position.toInt p1) ^
                      "-" ^ Int.toString(Position.toInt p2) ^
                      "@" ^ ST.getString(!SymbolTables.varTable, ctxt) ^
                      ":" ^ tStr
                     ,"\n\tuse at ", si)
                  end
               fun printB ({name,ty,width,uses,nested}, (str, si)) =
                  let
                     val visible = case debugSymbol of
                           NONE => true
                         | (SOME sid) => sid=SymbolTable.toInt name
                     val (tStr, si) = prBTyOpt (ty, " : ", si)
                     val (wStr, si) = prTyOpt (width, ", width = ", si)
                     val (uStr, _, si) = 
                           List.foldl printU ("", "\n\tuse at ", si)
                                      (SpanMap.listItemsi uses)
                     fun showBindInfosSI n (b :: bs,si) =
                        let
                           val (bStr, si) = showBindInfoSI (b,si)
                           fun spaces n = if n<=0 then "" else "  " ^ spaces (n-1)
                           val sStr = spaces n
                           val (bsStr, si) = showBindInfosSI (n+1) (bs, si)
                           val fs1 = Substring.fields (fn c => c= #"\n") (Substring.full bStr)
                           val fs2 = Substring.fields (fn c => c= #"\n") (Substring.full bsStr)
                        in
                           (List.foldl
                              (fn (f,str) => str ^ sStr ^ Substring.string f ^ "\n")
                              "\n" (fs1 @ fs2),
                            si)
                        end
                       | showBindInfosSI n ([], si) = ("", si)
                     val (nStr, si) = showBindInfosSI 1 (nested,si)
                  in
                    if not visible then (str, si) else
                    (str ^
                     "\n  " ^ ST.getString(!SymbolTables.varTable, name) ^
                     tStr ^ wStr ^ nStr ^ uStr
                    ,si)
                  end
                val (bsStr, si) = List.foldr printB ("", si) bs
            in
               ("GROUP" ^ bsStr, si)
            end
               
   end
   
   type environment = Scope.environment

   fun toStringSI ((scs, state),si) = 
      let
         fun showCons (s, (str, si)) =
            let
               val (bStr, si) = Scope.toString (s, si)
            in
               (bStr ^ "\n" ^ str, si)
            end
         val (sStr, si) = SC.toStringSI (Scope.getSize state, NONE, si)
         val (envConsStr, si) =
            List.foldr showCons ("sizes: " ^ sStr ^ "\n", si) scs
         fun showCtxt [] = "top level"
           | showCtxt [f] = ST.getString(!SymbolTables.varTable, f)
           | showCtxt (f::fs) = showCtxt [f] ^ ";" ^ showCtxt fs
      in
         ("environment at " ^ showCtxt (Scope.getCtxt state) ^ "\n" ^
          envConsStr ^ BD.showBFun (Scope.getFlow state) ^ "\n", si)
      end

   fun toString env =
      let
         val (str, _) = toStringSI (env,TVar.emptyShowInfo)
      in
         str
      end
   
   fun topToStringSI ((scs, state), si) =
        toStringSI (((List.rev (List.drop (List.rev scs, 2))), state), si)

   fun topToString env =
      let
         val (str, _) = topToStringSI (env,TVar.emptyShowInfo)
      in
         str
      end

   fun kappaToStringSI (env, si) = (case Scope.unwrap env of
        (KAPPA {ty = t}, _) =>
         let
            val (tStr, si) = showTypeSI (t,si)
         in
            (tStr ^ "\n", si)
         end
      | _ => raise InferenceBug
   )

   fun kappaToString env =
      let
         val (str, _) = kappaToStringSI (env,TVar.emptyShowInfo)
      in
         str
      end

   fun funTypeToStringSI (env, f, si) = (case Scope.lookup (f,env) of
        (_, COMPOUND { ty = SOME (t,_), width, uses, nested }) =>
            showTypeSI (t,si)
      | _ => raise InferenceBug
   )

   fun primitiveEnvironment (l,scs) = Scope.initial
      (GROUP (List.map (fn (s,t,bFunGen,ow) =>
         {name = s, ty = SOME (t,bFunGen BD.empty),
          width = ow, uses = SpanMap.empty, nested = []}) l),
       scs)
   
   fun pushSingle (sym, t, env) = Scope.wrap (SINGLE {name = sym, ty = t},env)
   
   structure SymbolSet = RedBlackSetFn (
      struct
         type ord_key = SymbolTable.symid
         val compare = SymbolTable.compare_symid
      end)
          
   fun pushGroup (syms, env) = 
      let
         val (funs, nonFuns) = List.partition (fn (s,dec) => not dec) syms
         val funDefs = List.map
            (fn (s,_) => {name = s, ty = NONE, width = NONE,
                          uses = SpanMap.empty, nested = []})
            funs
         val nonFunSyms =
            SymbolSet.listItems (SymbolSet.fromList (List.map (fn (s,_) => s) nonFuns))
         val nonFunDefs = List.map
            (fn s => {name = s, ty = NONE, width =
              SOME (VAR (TVar.freshTVar (), BD.freshBVar ())),
              uses = SpanMap.empty, nested = []}) nonFunSyms
      in                                                                    
         Scope.wrap (GROUP (funDefs @ nonFunDefs), env)
      end                                    

   fun popGroup (env, true) = (case Scope.unwrap env of
        (KAPPA {ty=t}, env) =>
         let
           val (badUses, env) = popGroup (env, false)
         in
            (badUses, Scope.wrap (KAPPA {ty=t}, env))
         end
       | _ => raise InferenceBug)
     | popGroup (env, false) = case Scope.unwrap env of
        (GROUP bs, env) =>
         let
            val remVars = Scope.getVars env
            val (scs, state) = env
            (*figure out if there are any function usages that have unresolved
            type variables that relate to sizes*)
            val curVars = SC.getVarset (Scope.getSize state)
            val unbounded = TVar.difference (curVars,remVars)
            (*val _ = TextIO.print ("unbounded vars: " ^ #1 (TVar.setToString (unbounded,TVar.emptyShowInfo)) ^ "\n")*)
            val siRef = ref TVar.emptyShowInfo
            fun showUse (n, (ctxt,t)) =
               let
                  val nStr = SymbolTable.getString(!SymbolTables.varTable, n)
                  val (tStr, si) = showTypeSI (t, !siRef)
                  val vs = texpVarset (t,TVar.empty)
                  val (cStr, si) = SC.toStringSI (Scope.getSize state, SOME vs, si)
               in
                  (siRef := si
                  ; nStr ^ " : call to " ^ tStr ^ " has ambiguous vector sizes" ^
                     (if String.size cStr=0 then "" else " where " ^ cStr))
               end
            fun remBoundVars ({name,ty=SOME (t,_),width,uses,nested=ns},vs) =
                  List.foldl remBoundVars 
                     (TVar.difference (vs, texpVarset (t,TVar.empty)))
                     (List.concat (List.map (fn g => case g of
                          GROUP bs => bs
                        | _ => raise InferenceBug) ns))
              | remBoundVars (_,vs) = vs
            val unbounded = List.foldl remBoundVars unbounded bs
            (*TODO: we should also descend into the nested definitions,
            since the letrec expression cannot report ambigueties since
            when letrec groups are popped, the fixpoint has not been
            calculated yet*)
            val badSizes = List.concat (
               List.map (fn {name = n,ty,width,uses = us,nested} =>
                  List.map (fn (sp,t) => (sp, showUse (n, t))) (
                     SpanMap.listItemsi (
                        SpanMap.filter (fn (_,t) =>
                           not (TVar.isEmpty (TVar.intersection
                              (texpVarset (t,TVar.empty), unbounded)))
                           ) us))) bs)
            (*project out variables from the size and Boolean domains that are
            no longer needed*)
            val sCons = SC.filter (remVars, Scope.getSize state)
            val env = (scs, Scope.setSize sCons state)
            
            (*in case we are inside a function, store this group in the nested
            field of the function entry*)
            val bs = if List.null (Scope.getCtxt state) then [] else bs
            (* the following filters out those functions that aren't needed;
              however, it is too aggressive as certain functions that are
              defined in the "in" part of a let may reference a function of
              the let body but are not visible *)
            (*val inScope = SymSet.fromList (Scope.getCtxt state)
            val _ = TextIO.print ("popGroup: in scope are " ^ List.foldl (fn (s,acc) => SymbolTable.getString(!SymbolTables.varTable, s) ^ ", " ^ acc) "" (Scope.getCtxt state) ^ "\n")
            val _ = TextIO.print ("popGroup: group symbols are " ^ List.foldl (fn ({name, ty, width, uses, nested},acc) => SymbolTable.getString(!SymbolTables.varTable, name) ^ ", " ^ acc) "" bs ^ "\n")
            val bs = List.filter
                        (fn {name, ty, width, uses = us, nested} =>
                           (if SymbolTable.toInt name=1630 then TextIO.print ("usages of conv-mem are " ^ List.foldl (fn ((name,_),acc) => SymbolTable.getString(!SymbolTables.varTable, name) ^ ", " ^ acc) "" (SpanMap.listItems us) ^ " with " ^ Int.toString (List.length nested) ^ " nested\n") else ();
                           List.exists (fn (f,_) => SymSet.member (inScope,f))
                              (SpanMap.listItems us) )
                        ) bs*)
            fun action group (COMPOUND {ty, width, uses, nested},cons) =
               (COMPOUND {ty = ty, width = width,
                uses = uses, nested = group :: nested}, cons)
              | action ns _ = raise InferenceBug
            val env = if List.null bs then env else
               Scope.update (Scope.getCurFun state, action (GROUP bs), env)
            (*val _ = if not (List.null bs) then
                    TextIO.print ("popGroup, updating " ^ SymbolTable.getString(!SymbolTables.varTable, Scope.getCurFun state) ^
                              " to contain group " ^ List.foldl (fn ({name, ty, width, uses, nested},acc) => SymbolTable.getString(!SymbolTables.varTable, name) ^ ", " ^ acc) "" bs ^ "\n" ^ topToString env)
                    else ()*)
         in
            (badSizes, env)
         end
      | _ => raise InferenceBug

   fun getGroupSyms env = case Scope.unwrap env of
        (GROUP bs, env) => List.map #name bs
      | _ => raise InferenceBug

   fun pushTop env = 
      let
         val a = TVar.freshTVar ()
         val b = BD.freshBVar ()
      in
         Scope.wrap (KAPPA {ty = VAR (a,b)}, env)
      end

   fun pushType (true, t, (scs, state)) =
      let
         val (t,bFun,sCons) = instantiateType (TVar.empty,t,TVar.empty,
                                               Scope.getFlow state,
                                               Scope.getSize state)
      in
         (Scope.wrap (KAPPA {ty = t}, (scs, Scope.setSize sCons (
                                             Scope.setFlow bFun state))))
      end
     | pushType (false, t, env) = Scope.wrap (KAPPA {ty = t}, env)

   fun pushMonadType (t, (scs, state)) =
      let
         val tvar = TVar.freshTVar ()
         val fromBVar = BD.freshBVar ()
         val toBVar = BD.freshBVar ()
         val fromVar = VAR (tvar, fromBVar)
         val toVar = VAR (tvar, toBVar)
         val bFun = BD.meetVarImpliesVar (fromBVar, toBVar) (Scope.getFlow state)
         val (t,bFun,sCons) = instantiateType (texpVarset(t,TVar.empty),t,
                                               TVar.empty,
                                               bFun,
                                               Scope.getSize state)
      in
         Scope.wrap (KAPPA {ty = MONAD (t, fromVar, toVar)},
                     (scs, Scope.setSize sCons (Scope.setFlow bFun state)))
      end

   fun pushWidth (sym, env) =
      (case Scope.lookup (sym,env) of
          (_, COMPOUND {ty, width = SOME t, uses, nested}) =>
            Scope.wrap (KAPPA {ty = t}, env)
        | _ => raise (UnificationFailure (Clash,
            SymbolTable.getString(!SymbolTables.varTable, sym) ^
            " is not a decoder"))
      )

   exception LookupNeedsToAddUse

   fun eq_span ((p1s,p1e), (p2s,p2e)) =
      Position.toInt p1s=Position.toInt p2s andalso
      Position.toInt p1e=Position.toInt p2e

   fun reduceBooleanFormula (sym,t,setType,reduceToMono,env) =
      let
         (*we need to restrict the size of the Boolean formula in two
         ways: first, for the function we need all Boolean variables
         in its type, all lambda- and kappa-bound types in the
         environment as well as all the uses of other functions that
         occur in it; secondly, the analysis must continue with a
         Boolean formula that contians the Boolean variables of all
         lambda- and kappa-bound types in the environment. Since the
         latter is usually an empty environment (namely for all
         top-level functions), we first calculate the set of Boolean
         variables in kappa- and lambda-bound types and use that for
         the Boolean formula of the function; then we project onto
         the variables in kappa- and lambda-bound types*)
         val texpBVarset = texpBVarset (fn ((_,v),vs) => BD.addToSet (v,vs))

         val (monoTVars, monoBVars) = Scope.getMonoVars env
         val (usesTVars, usesBVars) = Scope.getVarsUses (sym, env)
         val funBVars = texpBVarset (t,
                           BD.union (monoBVars, usesBVars))
                           
         val (scs, state) = env
         val bFun = BD.projectOnto (funBVars,Scope.getFlow state)
         val bFunRem = if reduceToMono then BD.projectOnto (monoBVars,bFun)
                       else bFun
         (*val _ = TextIO.print ("projecting for " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ ": " ^ showType t ^ " where \n" ^ toString env)*)
         val groupTVars = texpVarset (t,Scope.getVars env)
         val sCons = SC.filter (groupTVars, Scope.getSize state)
         val state = Scope.setSize sCons (Scope.setFlow bFunRem state)
         val env = Scope.update (sym, setType (t,bFun), (scs, state))
      in
         env
      end

   fun affectedFunctions (substs, env) =
      let
         fun aF (ss, substs, ([], _)) = ss
           | aF (ss, substs, env) =
               if isEmpty substs then ss else aFB ss (Scope.unwrap env)
         and aFB ss (GROUP l,env) =
            let
               fun aFL (ss, []) =
                   aF (ss, substsFilter (substs, Scope.getVars env), env)
                 | aFL (ss, {name = n, ty, width, uses = us, nested = ns} :: l) =
                     List.foldl (fn (b,ss) => aFB ss (b,env))
                     (if List.all (fn (_,t) => isEmpty
                              (substsFilter (substs, texpVarset (t,TVar.empty))))
                           (SpanMap.listItems us)
                     then aFL (ss, l)
                     else aFL (SymbolSet.add' (n, ss), l)
                     ) ns
            in
               aFL (ss, l)
            end
           | aFB ss (_, env) =
               aF (ss, substsFilter (substs, Scope.getVars env), env)
      in
         aF (SymbolSet.empty, substs, env)
      end

   fun affectedField (bVars, env as (scs,state)) =
      let
         fun aF (_, SOME f) = SOME f
           | aF (([],_), NONE) = NONE
           | aF (env, NONE) = case Scope.unwrap env of
              (KAPPA {ty = t}, env) =>
               aF (env, fieldOfBVar (bVars, t))
            | (SINGLE {name, ty = t}, env) => aF (env, fieldOfBVar (bVars, t))
            | (GROUP l, env) =>
            let
               fun findField ((_,t), SOME f) = SOME f
                 | findField ((_,t), NONE) = fieldOfBVar (bVars, t)
               fun aFL {name, ty = tOpt, width, uses, nested} =
                  List.foldl findField
                     (case tOpt of
                          NONE => NONE
                        | SOME (t,_) => fieldOfBVar (bVars, t))
                     (SpanMap.listItems uses)
            in
               aF (env, case List.mapPartial aFL l of
                       [] => NONE
                     | (f :: _) => SOME f)
            end
      in
         aF (env, NONE)
      end

   fun flowError (bVar, fOpt, envs) =
      let
         val fOpt = List.foldl (fn (env,res) => case res of
                       SOME f => SOME f
                     | NONE => affectedField (bVar, env)) fOpt envs
         val fStr = case fOpt of
                 NONE => "some field"
               | SOME f => "field " ^
                  SymbolTable.getString(!SymbolTables.fieldTable, f)
         val fStr = if Types.concisePrint then fStr else
                    fStr ^ " with vars " ^ BD.setToString bVar
      in
         raise UnificationFailure (Clash, fStr ^ " may not be present")
      end

   fun meetBoolean (update, env as (scs, state)) =
      (scs, Scope.setFlow (update (Scope.getFlow state)) state)
         handle (BD.Unsatisfiable bVar) => flowError (bVar, NONE, [env])

   fun reduceFlow (env as (scs, state)) =
      (scs, Scope.setFlow (BD.projectOnto (Scope.getBVars env, Scope.getFlow state)) state)
         handle (BD.Unsatisfiable bVar) => flowError (bVar, NONE, [env])

   fun meetSizeConstraint (update, (scs, state)) =
      (scs, Scope.setSize (update (Scope.getSize state)) state)

   fun genConstructorFlow (contra, env) = case Scope.unwrap env of
        (KAPPA {ty=FUN ([t], ALG (_,vs))}, _) =>
         let
            val dtVars = List.map (fn v => case v of
                             VAR p => p
                           | _ => raise InferenceBug) vs
            val flow = texpConstructorFlow dtVars contra t
            val env = meetBoolean (fn bFun => BD.meet (flow,bFun), env)
         in
            env
         end
      | _ => raise InferenceBug

   fun pushSymbol (sym, span, recordUsage, createInstance, env) = (
      if SOME (SymbolTable.toInt sym)=debugSymbol then
         TextIO.print ("pushSymbol debug symbol:\n" ^ toString env) else ();
      case Scope.lookup (sym,env) of
          (_, SIMPLE {ty = t}) =>
         let
            val tNew = setFlagsToTop t
            val env = Scope.wrap (KAPPA {ty = tNew}, env)
            val l1 = texpBVarset (op ::) (t, [])
            val l2 = texpBVarset (op ::) (tNew, [])
            fun genImpl ((contra1,f1),(contra2,f2),bf) =
               if contra1<>contra2 then raise InferenceBug else
               if contra1 then
                  BD.meetVarImpliesVar (f2,f1) bf
               else
                  BD.meetVarImpliesVar (f1,f2) bf
         in
            meetBoolean (fn bFun => ListPair.foldlEq genImpl bFun (l2, l1), env)
         end
        | (tvs, COMPOUND {ty = SOME (t,bFunFun), width = w, uses, nested}) =>
         let
            val (scs,state) = env
            val bFunFun = BD.projectOnto (
                  texpBVarset (fn ((_,v),vs) => BD.addToSet (v,vs)) (t, BD.emptySet),
                  bFunFun)
            val bFun = BD.meet (bFunFun, Scope.getFlow state)
            val decVars = case w of
                 SOME t => texpVarset (t,TVar.empty)
               | NONE => TVar.empty
            val (t,bFun,sCons) =
               if createInstance then
                  instantiateType (tvs, t, decVars, bFun, Scope.getSize state)
               else
                  (t,bFun,Scope.getSize state)
            val env = (scs, Scope.setFlow bFun (Scope.setSize sCons state))
            (*we need to record the usage sites of all functions (primitives,
            really) that have explicit size constraints in order to be able
            to later generate error messages for ambiguous uses of these
            functions*)
            fun action (COMPOUND {ty, width, uses, nested},cons) =
               (COMPOUND {ty = ty, width = width,
                uses = SpanMap.insert (uses, span, (Scope.getCurFun state, t)),
                nested = nested}, cons)
              | action _ = raise InferenceBug
            val env =
               if not recordUsage andalso
                  TVar.isEmpty (TVar.intersection (decVars, SC.getVarset (Scope.getSize state)))
               then env
               else Scope.update (sym, action, env)
         in
            Scope.wrap (KAPPA {ty = t}, env)
         end
        | (_, COMPOUND {ty = NONE, width, uses, nested}) =>
          (case SpanMap.find (uses, span) of
               SOME (_,t) => Scope.wrap (KAPPA {ty = t}, env)
             | NONE =>
             let
                val (scs,state) = env
                val res = freshVar ()
                fun action (COMPOUND {ty, width, uses, nested},cons) =
                     (COMPOUND {ty = ty, width = width,
                      uses = SpanMap.insert (uses, span, (Scope.getCurFun state,res)),
                      nested = nested}, cons)
                  | action _ = raise InferenceBug
                val env = Scope.update (sym, action, env)
                (*val _ = TextIO.print ("added usage for " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " with state " ^ #1 (TVar.setToString (Scope.getVars env,TVar.emptyShowInfo)) ^ "\n")*)
             in
                Scope.wrap (KAPPA {ty = res}, env)
             end
          )
      )

   fun getUsages (sym, env) = (case Scope.lookup (sym, env) of
           (_, SIMPLE {ty}) => []
         | (_, COMPOUND {ty, width, uses = us, nested}) => SpanMap.listKeys us
         )

   fun getContextOfUsage (sym, span, env) = (case Scope.lookup (sym, env) of
           (_, SIMPLE {ty}) => raise InferenceBug
         | (_, COMPOUND {ty, width, uses = us, nested}) => 
           #1 (SpanMap.lookup (us, span))
         )

   fun pushUsage (sym, span, env) = (case Scope.lookup (sym, env) of
           (_, SIMPLE {ty}) => raise InferenceBug
         | (_, COMPOUND {ty, width, uses = us, nested}) =>
            let
               val (fid, t) = SpanMap.lookup (us, span)
               (*fun gatherBFun (f,bFun) =
                  case List.find (fn (f',_) => ST.eq_symid (f,f')) funList of
                       SOME (_, VALUE { symFlow = bFun', ... }) =>
                        BD.meet (bFun',bFun)
                     | SOME (_, DECODE { symFlow = bFun', ... }) =>
                        BD.meet (bFun',bFun)
                     | NONE => bFun
               fun addUsageBFun bFun = List.foldl gatherBFun bFun fs
               val env = meetBoolean (addUsageBFun, env)*)
            in
               Scope.wrap (KAPPA {ty = t}, env)
            end
         )

   fun getCtxt (scs, state) = Scope.getCtxt state

   fun popToUsage (sym, span, env) = (case Scope.unwrap env of
        (KAPPA {ty = tUse}, env) =>
         let
            val funRef = ref (NONE : SymbolTable.symid option)
            fun setUsage (COMPOUND {ty, width, uses = us, nested}, cons) =
               (case SpanMap.find (us,span) of
                    NONE => raise InferenceBug
                  | SOME (fid, _) =>
                     (funRef := SOME fid;
                     (COMPOUND {
                        ty = ty, width = width,
                        uses = SpanMap.insert (us,span,(fid,tUse)),
                        nested = nested
                     }, cons))
               )
              | setUsage _ = raise InferenceBug
            val env = Scope.update (sym, setUsage, env)
            fun setType t (COMPOUND {ty = _, width, uses, nested}, cons) =
                  (COMPOUND {ty = SOME t, width = width, uses = uses, nested = nested},
                   cons)
              | setType t _ = raise InferenceBug
            val fid = case !funRef of
                 SOME fid => fid
               | NONE => raise InferenceBug
            (*val _ = TextIO.print ("popToUsage " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ ":\n")*)
      
            val env = case Scope.lookup (fid,env) of
                 (_, COMPOUND { ty = SOME (t,_), width, uses, nested}) =>
                  reduceBooleanFormula (fid,t,setType,true,env)
               | _ => raise InferenceBug
         in
            env
         end
     | _ => raise InferenceBug)

   fun pushLambdaVar' (sym, env) =
      let
         val t = VAR (TVar.freshTVar (), BD.freshBVar ())
      in
         (t, Scope.wrap (SINGLE {name = sym, ty = t}, env))
      end

   fun pushLambdaVar (sym, env) =
      let
         val t = VAR (TVar.freshTVar (), BD.freshBVar ())
      in
         Scope.wrap (SINGLE {name = sym, ty = t}, env)
      end

   fun reduceToRecord (bns, env) =
      let
         fun genFields (fs, [], env) = (case Scope.unwrap env of
                 (KAPPA {ty=VAR (tv,bv)}, env) =>
                  Scope.wrap (KAPPA {ty = RECORD (tv, bv, fs)}, env)
               | _ => raise InferenceBug
            )
           | genFields (fs, (bVar, fName) :: bns, env) =
               (case Scope.unwrap env of
                    (KAPPA {ty=t}, env) =>
                        genFields (insertField (
                           RField { name = fName, fty = t, exists = bVar},
                           fs), bns, env)
                  | _ => raise InferenceBug)
      in
         genFields ([], bns, env)
      end

   fun reduceToSum (n, env) =
      let
         fun rTS (n, vars, const, env) = if n>0 then
               case Scope.unwrap env of
                    (KAPPA {ty = CONST c}, env) => rTS (n-1, vars, c+const, env)
                  | (KAPPA {ty = VAR (v,_)}, env) => rTS (n-1, v::vars, const, env)
                  | _ => raise InferenceBug
            else case vars of
                 [] => Scope.wrap (KAPPA {ty = CONST const}, env)
               | [v] => Scope.wrap (KAPPA {ty = VAR (v, BD.freshBVar ())}, env)
               | vs =>
                  let
                     val v = TVar.freshTVar ()
                     val scs = SC.fromList [SC.equality (v, vs, const)]
                     val env = meetSizeConstraint
                                 (fn scs' => SC.merge (scs,scs'), env)
                     (*val (scsStr,si) = SC.toStringSI (scs, NONE, TVar.emptyShowInfo)
                     val (eStr, si) = topToStringSI (env, si)
                     val _ = TextIO.print ("reduceToSum: " ^ scsStr ^ ", resulting in\n" ^ eStr ^ "\n")*)
                  in
                     Scope.wrap (KAPPA { ty = VAR (v, BD.freshBVar ())}, env)
                  end
      in
         rTS (n, [], 0, env)
      end

   fun reduceToFunction (env,nArgs) =
      if nArgs=0 then env else
      let
         val (tRes, env) = case Scope.unwrap env of
                             (KAPPA {ty = t}, env) => (t,env)
                           | (SINGLE {name, ty = t}, env) => (t,env)
                           | _ => raise InferenceBug
         fun getArgs (tys,n,env) = if n=0 then (tys,env) else
            case Scope.unwrap env of
                 (KAPPA {ty = t}, env) => getArgs (t :: tys,n-1,env)
               | (SINGLE {name, ty = t}, env) => getArgs (t :: tys,n-1,env)
               | _ => raise InferenceBug
         val (tArgs,env) = getArgs ([],nArgs,env)
      in
         Scope.wrap (KAPPA {ty = FUN (tArgs,tRes)}, env)
      end

   fun reduceToResult env = case Scope.unwrap env of
           (KAPPA {ty = FUN (t1,t2)}, env) =>
            Scope.wrap (KAPPA {ty = t2}, env)
         | _ => raise InferenceBug

   fun reduceToArgument env = case Scope.unwrap env of
           (KAPPA {ty = FUN ([t1],t2)}, env) =>
            Scope.wrap (KAPPA {ty = t1}, env)
         | _ => raise InferenceBug

   (* local helper: equate or imply the flags of two types *)
   fun flowForType (directed,t1,t2,bFun) =
      let
         fun genImpl (t1,t2) ((contra1,f1), (contra2,f2),bFun) =
            if contra1<>contra2 then
               let
                  val (t1Str, si) = showTypeSI (t1,TVar.emptyShowInfo)
                  val (t2Str, si) = showTypeSI (t2,si)
                  val (mStr, si) = showSubstsSI (mgu (t1,t2,emptySubsts), si)
                  val _ = TextIO.print ("cannot gen impl flow from\n" ^ t1Str ^ "\nand\n" ^ t2Str ^ "\nsince mgu = " ^ mStr ^ "\n")
               in
                  raise InferenceBug
               end
            else if BD.eq(f1,f2) then bFun else
            let
               (*val _ = TextIO.print ("add directed flow: " ^ BD.showVar f1 ^
                  (if contra1 then "<-" else "->") ^ BD.showVar f2 ^ "\n")*)
            in
               if contra1 then BD.meetVarImpliesVar (f2,f1) bFun
               else BD.meetVarImpliesVar (f1,f2) bFun
            end
      in
         if directed then
            ListPair.foldlEq (genImpl (t1,t2)) bFun
               (texpBVarset (op ::) (t1, []), texpBVarset (op ::) (t2, []))
         else
         let
            (*val _ = TextIO.print ("forcing bVars to be equal:" ^
               ListPair.foldlEq (fn (f1,f2,str) => str ^ " " ^ BD.showVar f1 ^ "=" ^ BD.showVar f2) ""
               (texpBVarset (fn ((_,f),fs) => f::fs) (t1, []),
                texpBVarset (fn ((_,f),fs) => f::fs) (t2, [])) ^ "\n")*)
         in
            ListPair.foldlEq BD.meetEqual bFun
               (texpBVarset (fn ((_,f),fs) => f::fs) (t1, []),
                texpBVarset (fn ((_,f),fs) => f::fs) (t2, []))
         end
      end

   fun return (n,env) =
      let
         val (t, env) = Scope.unwrap env
         fun popN (n,env) = if n<=0 then env else
            let
               val (_, env) = Scope.unwrap env
            in
               popN (n-1, env)
            end
      in
         Scope.wrap (t, popN (n,env))
      end

   fun popKappa env = case Scope.unwrap env of
        (KAPPA {ty}, env) => env
      | _ => raise InferenceBug

   fun equateKappasGeneric (env,directed) =
      let
         fun getKappaTypes env =
            case Scope.unwrap env of
              (KAPPA {ty=t1}, env) => (case Scope.unwrap env of
                 (KAPPA {ty=t2}, env) => (t2,t1)
               | (SINGLE {ty=t2, ...}, env) => (t2,t1)
               | _ => raise InferenceBug) 
            | _ => raise InferenceBug

         fun substBinding (substs, KAPPA {ty=t}, ei) =
            (case applySubstsToExp substs (t,ei) of (t,ei) =>
               (KAPPA {ty = t}, ei))
           | substBinding (substs, SINGLE {name = n, ty = t}, ei) =
            (case applySubstsToExp substs (t,ei) of (t,ei) =>
               (SINGLE {name = n, ty = t}, ei))
           | substBinding (substs, GROUP bs, ei) =
               let
                  val eiRef = ref ei
                  fun optSubst (SOME t) =
                     (case applySubstsToExp substs (t,!eiRef) of (t,ei) =>
                        (eiRef := ei; SOME t))
                    | optSubst NONE = NONE
                  fun optBSubst (SOME (t,bFun)) =
                     (case applySubstsToExp substs (t,!eiRef) of (t,ei) =>
                        (eiRef := ei; SOME (t,bFun)))
                    | optBSubst NONE = NONE
                  fun usesSubst (ctxt,t) =
                     (case applySubstsToExp substs (t,!eiRef) of (t,ei) =>
                        (eiRef := ei; (ctxt,t)))
                  fun substB {name = n, ty = t, width = w, uses = us, nested = ns} =
                     {name = n, ty = optBSubst t, width = optSubst w,
                      uses = SpanMap.map usesSubst us,
                      nested = List.map (fn b =>
                           case substBinding (substs, b, !eiRef) of
                              (b, ei) => (eiRef := ei; b)
                        ) ns
                     }
               in
                  (GROUP (List.map substB bs), !eiRef)
               end

         fun descent (ei,substs,env) =
            if isEmpty substs then (ei,env) else
            let
               val (b, env) = Scope.unwrap env
               val (b, ei) = substBinding (substs, b, ei)
               val substs = substsFilter (substs, Scope.getVars env)
               val (ei, env) = descent (ei,substs,env)
            in
               (ei, Scope.wrap (b,env))
            end

         val (t1,t2) = getKappaTypes env
         val substs = mgu (t1,t2,emptySubsts)
         
         (* apply substitutions to types *)
         val (ei,env) = descent (emptyExpandInfo,substs,env)
                     
         (* apply substitutions to sizes *)
         val (scs, state) = env
         val (sCons, substs) = applySizeConstraints (Scope.getSize state, substs)
         val state = Scope.setSize sCons state

         (* apply expand info ei to Boolean formula *)
         val bVars = Scope.getBVars env
         val bVars = expandInfoGetBVars (ei, bVars)
         
         val bFun = Scope.getFlow state
         val bFun = BD.projectOnto (bVars, bFun)
         val bFun = applyExpandInfo ei bFun
            handle (BD.Unsatisfiable bVar) =>
               flowError (bVar, NONE, [env])

         (* generate flow between kappas *)
         val (t1,t2) = getKappaTypes env
         val bFun = flowForType (directed,t1,t2,bFun)
            handle (BD.Unsatisfiable bVar) => flowError (bVar, NONE, [return (1,env),popKappa env])
         val state = Scope.setFlow bFun state

      in
         (scs, state)
      end
      

   fun equateKappas env = equateKappasGeneric (env,true) 
   fun equateKappasFlow env = equateKappasGeneric (env,false)

   fun flipKappas env = case Scope.unwrap env of
              (KAPPA {ty=t1}, env) => (case Scope.unwrap env of
                 (KAPPA {ty=t2}, env) => Scope.wrap (KAPPA {ty=t2},Scope.wrap (KAPPA {ty=t1},env))
               | _ => raise InferenceBug) 
            | _ => raise InferenceBug

   fun subsetKappas env =
      let
         fun getKappaTypes env =
            case Scope.unwrap env of
              (KAPPA {ty=t2}, env) => (case Scope.unwrap env of
                 (KAPPA {ty=t1}, env) => (t1,t2)
               | (SINGLE {ty=t1, ...}, env) => (t1,t2)
               | _ => raise InferenceBug) 
            | _ => raise InferenceBug

         val (t1,t2) = getKappaTypes env
         val substs = mgu (t1,t2,emptySubsts)
         val substs = substsFilter (substs, texpVarset (t1, TVar.empty))

         (*val (t1Str,si) = showTypeSI (t1,TVar.emptyShowInfo)
         val (t2Str,si) = showTypeSI (t2,si)
         val (sStr, _) = showSubstsSI (substs,si)
         val _ = TextIO.print ("subsetKappas: " ^ t1Str ^ " <= " ^ t2Str ^ " gives " ^ sStr ^ "\n")*)


      in
         substs
      end

   fun popToFunction (sym, env) =
      let
         (*val ctxt = getCtxt env
         val _ = if List.all (fn x => SymbolTable.toInt x<>427) ctxt then () else
                 TextIO.print ("popToFunction " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ ":\n" ^ toString env)*)
         fun setType t (COMPOUND {ty = NONE, width, uses, nested}, cons) =
               (COMPOUND {ty = SOME t, width = width, uses = uses, nested = nested},
                cons)
           | setType t _ = (TextIO.print ("popToFunction " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ ":\n" ^ toString env); raise InferenceBug)
      in
         case Scope.unwrap env of
              (KAPPA {ty=t}, (scs,state)) =>
              (
(*let
   fun checkField bVar =
      (case BD.meetVarZero bVar (Scope.getFlow state) of _ => true)
      handle (BD.Unsatisfiable bVars) => false
   val _ = if SymbolTable.toInt sym <> 82 then () else
      case t of
         MONAD (_,RECORD (_,_,fs),_) =>
            (case List.find (fn (RField { name = fid, ...}) => SymbolTable.toInt fid = 31) fs of
              NONE => ()
            | SOME (RField { exists = bVar, ... }) =>
             if checkField bVar then () else
             TextIO.print ("HERE!\n")
            )
       | _ => ()
in () end;*)
               reduceBooleanFormula (sym,t,setType,true, (scs, state))
              )
            | _ => raise InferenceBug
      end

   fun enterFunction (sym, (scs,state)) =
      (scs, Scope.setCtxt (sym :: Scope.getCtxt state) state)

   fun leaveFunction (sym, (scs,state)) =
      case Scope.getCtxt state of
           (fid :: fids) =>
            if SymbolTable.eq_symid(fid,sym) then (scs, Scope.setCtxt fids state)
            else raise InferenceBug
         | [] => raise InferenceBug


   fun inScope (sym,([],_)) = false
     | inScope (sym,env) = case Scope.unwrap env of
        (GROUP bs,env) =>
         if List.exists (fn {name, ty, width, uses, nested} =>
                           SymbolTable.eq_symid (sym,name)) bs then true
         else inScope (sym,env)
      | (_,env) => inScope (sym,env)
      
   fun pushNested (sym, env) =
      if inScope (sym,env) then (0,env) else
      let
         val (sc,_) = Scope.unwrap env
         fun findSymInGroups (n, ns, env) =
            List.foldl
               (fn (g,res) => case res of
                    SOME r => SOME r
                  | NONE => findSymInGroup (n+1,g,Scope.wrap (g, env))
               ) NONE ns
         and findSymInGroup (n,GROUP bs,env) =
            (case List.find (fn {name, ty, width, uses, nested} =>
                              SymbolTable.eq_symid (sym,name)) bs of
               SOME {name, ty, width, uses, nested} =>
                  SOME (n, env)
             | NONE =>
               List.foldl (fn ({name, ty, width, uses, nested=ns},res) =>
                  case res of
                     SOME r => SOME r
                   | NONE => findSymInGroups (n, ns, env)
               ) NONE bs
            )
           | findSymInGroup (n,_,env) = raise InferenceBug
      in
         case findSymInGroup (0, sc, env) of
              NONE => (0,env)
            | SOME r => r
      end
   
   fun popNested (n, env) = if n<=0 then env else
      case Scope.unwrap env of
        (GROUP bs, env) => (case Scope.unwrap env of
             (GROUP bsPrev, env) =>
               let
                  fun replGroup (GROUP bs' :: gs) =
                     if List.all (fn (b,b') =>
                           SymbolTable.eq_symid (#name b, #name b'))
                        (ListPair.zip (bs,bs'))
                     then GROUP bs :: gs else GROUP bs' :: replGroup gs
                    | replGroup [] = []
                    | replGroup _ = raise InferenceBug
                  
                  fun replBs ({name, ty, width, uses, nested}) =
                     {name = name, ty = ty, width = width,
                      uses = uses, nested = replGroup nested}
                  val bsPrev = List.map replBs bsPrev
                  val env = Scope.wrap (GROUP bsPrev,env)
               in
                  popNested (n-1,env)
               end
            | _ => raise InferenceBug
          )
      | (_, env) => raise InferenceBug

   fun clearFunction (sym, env) =
      let
         val tOptRef = ref (NONE : (texp * BD.bfun) option)
         fun resetType (COMPOUND {ty = tOpt, width, uses, nested}, cons) =
               (tOptRef := tOpt
               ;(COMPOUND {ty = NONE, width = width, uses = uses, nested = nested}, cons))
           | resetType _ = raise InferenceBug
         val env = Scope.update (sym, resetType, env)
      in
         case !tOptRef of
              NONE => NONE
            | SOME (ty,flow) =>
               SOME (meetBoolean (
                     fn bFun => BD.meet (flow,bFun),
                     Scope.wrap (KAPPA { ty = ty },env)))
      end
   
   fun forceNoInputs (sym, fields, env) = case Scope.lookup (sym,env) of
               (_,COMPOUND {ty = SOME (t,bFun), width, uses, nested}) =>
               let
                  val fs = case t of
                       (MONAD (r,RECORD (_,_,fs),out)) => fs
                     | FUN (args,(MONAD (r,RECORD (_,_,fs),out))) =>
                        List.foldl (fn (arg,fs) => case arg of
                             RECORD (_,_,fs') => fs' @ fs
                           | _ => fs) fs args
                     | FUN (args,_) =>
                        List.foldl (fn (arg,fs) => case arg of
                             RECORD (_,_,fs') => fs' @ fs
                           | _ => fs) [] args
                     | _ => []
                  fun checkField bVar =
                     (case BD.meetVarZero bVar bFun of _ => true)
                     handle (BD.Unsatisfiable bVars) => false
               in
                  List.foldl (fn (RField { name = f, fty, exists = bVar},fs) =>
                     if List.exists (fn s => SymbolTable.eq_symid(s,f)) fields
                     then fs
                     else if checkField bVar then fs else f :: fs)
                  [] fs
               end
             | (_,COMPOUND {ty = NONE, width, uses, nested}) => []  (*allow type errors*)
             | _ => raise InferenceBug

end
