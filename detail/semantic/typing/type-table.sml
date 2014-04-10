structure Path : sig
   
   type flowpoints

   val typeToFlowpoints : Types.texp -> flowpoints
   val varsOfFlowpoints : flowpoints -> TVar.tvar list
   val flagsOfFlowpoints : flowpoints -> (bool * BooleanDomain.bvar) list
   
   (* rename the first variable to the second one *)
   val renameVariable : TVar.tvar * TVar.tvar * flowpoints -> flowpoints
             
   type leaf
   val mkVarLeaf : TVar.tvar -> leaf
   val mkFieldLeaf : FieldInfo.symid -> leaf
   val getVarLeaf : leaf -> TVar.tvar option
   
   type steps
   val showSteps : steps -> string
   val emptySteps : steps
   val appendIntStep : int -> steps -> steps
   val appendFieldStep : FieldInfo.symid -> steps -> steps
   val prependIntStep : int -> (steps * leaf) -> (steps * leaf)
   val prependFieldStep : FieldInfo.symid -> (steps * leaf) -> (steps * leaf)
   val createFlowpoints : (steps * leaf) list -> flowpoints
   
   (* Determine if the new steps descend to a contravariant position *)
   val stepsContra : steps -> bool
   
   (* Replace the given type variable by the set of steps and new leaves. *)
   val insertSteps : flowpoints * TVar.tvar * (steps * leaf) list ->
         flowpoints * (BooleanDomain.bvar * BooleanDomain.bvar list) list
   val getFlag : flowpoints * (steps * leaf) -> BooleanDomain.bvar
   
   val findField : BooleanDomain.bvarset * flowpoints -> FieldInfo.symid option
   
   val toStringSI : (flowpoints * TVar.varmap) -> (string * TVar.varmap)

end = struct
   structure BD = BooleanDomain
   open Types
   
   datatype leaf
      = LeafField of FieldInfo.symid
      | LeafVar of TVar.tvar

   val mkVarLeaf = LeafVar
   val mkFieldLeaf = LeafField
   fun getVarLeaf (LeafVar v) = SOME v
     | getVarLeaf _ = NONE

   datatype step
      = StepIndex of int
      | StepField of FieldInfo.symid
   
   type steps = step list

   fun compareSteps ([],[]) = EQUAL
     | compareSteps (s1::ss1,[]) = GREATER
     | compareSteps ([],s2::ss2) = LESS
     | compareSteps (StepIndex i1::ss1,StepIndex i2::ss2) =
         (case Int.compare (i1,i2) of
            EQUAL => compareSteps (ss1,ss2)
          | res => res
         )
     | compareSteps (StepField f1::ss1,StepField f2::ss2) =
         (case SymbolTable.compare_symid (f1,f2) of
            EQUAL => compareSteps (ss1,ss2)
          | res => res
         )
     | compareSteps (StepIndex _::_,_) = LESS
     | compareSteps _ = GREATER

   fun compareLeaf (LeafField f1, LeafField f2) =
         SymbolTable.compare_symid (f1,f2)
     | compareLeaf (LeafVar v1, LeafVar v2) =
         TVar.compare (v1,v2)
     | compareLeaf (LeafVar _, LeafField _) = LESS
     | compareLeaf _ = GREATER
      
   fun showSteps p =
      let
         fun showStep (StepIndex i) = Int.toString i ^ "-"
           | showStep (StepField f) =
            SymbolTable.getString (!SymbolTables.fieldTable,f) ^ "-"
      in
         String.concat (List.map showStep p)
      end
   
   structure TVarMap = RedBlackMapFn(struct
      type ord_key = TVar.tvar
      val compare = TVar.compare
   end)           

   structure StepsMap = SplayMapFn(struct
      type ord_key = steps
      val compare = compareSteps
   end)           

   type flowpoints = (BD.bvar StepsMap.map TVarMap.map * BD.bvar StepsMap.map SymMap.map)

   fun toStringSI ((varMap, symMap) : flowpoints,si) =
      let
         fun showPaths vStr pm = StepsMap.foldli (fn (p,fi,pStr) =>
            pStr ^ showSteps p ^ vStr ^ BD.showVar fi ^ ";") "" pm
         fun showVarMapping (v,pm,(str,si)) =
            let
               val (varStr, si) = TVar.varToString (v,si)
            in
               (str ^ "\n  " ^ showPaths varStr pm, si)
            end
         val (vStr,si) = TVarMap.foldli showVarMapping ("",si) varMap
         fun showSymMapping (f,pm,str) =
            let
               val varStr = SymbolTable.getString (!SymbolTables.fieldTable,f)
            in
               str ^ "\n  " ^ showPaths varStr pm
            end
         val fStr = SymMap.foldli showSymMapping "" symMap
      in
         (vStr ^ fStr,si)
      end

   fun typeToFlowpoints ty =
      let
         fun addI (idx,paths) =
            List.map (fn (steps,leaf,flag) => (StepIndex idx :: steps,leaf,flag)) paths
         fun addIs (c,t::ts) = addI (c,t) @ addIs (c-1,ts)
           | addIs (c,[]) = []
           
         fun paths (FUN (ts, t)) = addIs (0,List.map paths (t :: ts))
           | paths (SYN (syn, t)) = paths t
           | paths (ZENO) = []
           | paths (FLOAT) = []
           | paths (STRING) = []
           | paths (UNIT) = []
           | paths (VEC t) = paths t
           | paths (CONST c) = []
           | paths (ALG (sym, l)) = addIs (List.length l, List.map paths l)
           | paths (RECORD (v,f,fs)) =
               ([],LeafVar v,f) :: List.concat (List.map pathsF fs)
           | paths (MONAD (r,a,b)) = addI (0,paths r) @ addI (~1,paths a) @ addI (1, paths b)
           | paths (VAR (v,f)) = [([],LeafVar v,f)]
          and pathsF (RField {name = n, fty = t, exists = b}) = ([],LeafField n,b) ::
            List.map (fn (steps,leaf,flag) => (StepField n :: steps,leaf,flag)) (paths t)
         
         fun insert ((path, LeafVar v, flag),(varMap, fieldMap)) =
            let
               val pathMap = case TVarMap.find (varMap, v) of
                     SOME pm => pm
                   | NONE => StepsMap.empty
               val pathMap = StepsMap.insert (pathMap, path, flag)
            in
               (TVarMap.insert (varMap, v, pathMap), fieldMap)
            end
           | insert ((path, LeafField f, flag),(varMap, fieldMap)) =
            let
               val pathMap = case SymMap.find (fieldMap, f) of
                     SOME pm => pm
                   | NONE => StepsMap.empty
               val pathMap = StepsMap.insert (pathMap, path, flag)
            in
               (varMap, SymMap.insert (fieldMap, f, pathMap))
            end
      in
         List.foldl insert (TVarMap.empty, SymMap.empty) (paths ty)
      end

   fun varsOfFlowpoints (vm,_) = TVarMap.listKeys vm
   
   fun stepsContra [] = false
     | stepsContra (StepIndex idx :: steps) =
         if idx<0 then not (stepsContra steps) else stepsContra steps
     | stepsContra (StepField _ :: steps) = stepsContra steps

   fun flagsOfFlowpoints (vm,fm) =
      let
         val pms = TVarMap.listItems vm @ SymMap.listItems fm
         val dirFlags = List.concat (List.map StepsMap.listItemsi pms)
      in
         List.map (fn (steps,f) => (stepsContra steps,f)) dirFlags
      end

   fun renameVariable (v1,v2,(vm,fm)) =
      let
         val (vm,prev) = TVarMap.remove (vm,v1)
         val vmNew = TVarMap.singleton (v2,prev)
         fun doublePath (p1,p2) = p1
         val vm = TVarMap.unionWith (StepsMap.unionWith doublePath) (vm, vmNew)
      in
         (vm,fm)
      end
   
   val emptySteps = []
   fun appendIntStep idx steps = steps @ [StepIndex idx]
   fun appendFieldStep sym steps = steps @ [StepField sym]
   fun prependIntStep idx (steps, leaf) = (StepIndex idx :: steps, leaf)
   fun prependFieldStep sym (steps, leaf) = (StepField sym :: steps, leaf)

   fun createFlowpoints sls =
      let
         fun insert ((path, LeafVar v),(varMap, fieldMap)) =
            let
               val pathMap = case TVarMap.find (varMap, v) of
                     SOME pm => pm
                   | NONE => StepsMap.empty
               val pathMap = StepsMap.insert (pathMap, path, BD.freshBVar ())
            in
               (TVarMap.insert (varMap, v, pathMap), fieldMap)
            end
           | insert ((path, LeafField f),(varMap, fieldMap)) =
            let
               val pathMap = case SymMap.find (fieldMap, f) of
                     SOME pm => pm
                   | NONE => StepsMap.empty
               val pathMap = StepsMap.insert (pathMap, path, BD.freshBVar ())
            in
               (varMap, SymMap.insert (fieldMap, f, pathMap))
            end
      in
         foldl insert (TVarMap.empty, SymMap.empty) sls
      end
   
   fun insertSteps ((tVarMap,fieldMap), oldVar, stepsLeafList) =
      if not (TVarMap.inDomain (tVarMap,oldVar)) then ((tVarMap,fieldMap), []) else
      let
         val expandInfo = ref []
         fun addSteps ((oldSteps,bVar),fp) =
            let
               val newStepsLeafList = List.map (fn (steps, leaf) =>
                     ((oldSteps @ steps, leaf), BD.freshBVar ())) stepsLeafList
               val bVars = List.map #2 newStepsLeafList
               val _ = expandInfo := (bVar, bVars) :: !expandInfo

               fun insertSteps (((steps,LeafVar tVar),bVar), (tVarMap,fieldMap)) =
                     (TVarMap.insert (tVarMap,tVar, case TVarMap.find (tVarMap,tVar) of
                        NONE => StepsMap.singleton (steps, bVar)
                      | SOME sm => StepsMap.insert (sm, steps, bVar)),
                      fieldMap
                     )
                 | insertSteps (((steps,LeafField sym),bVar), (tVarMap,fieldMap)) =
                     (tVarMap,
                      SymMap.insert (fieldMap,sym, case SymMap.find (fieldMap, sym) of
                        NONE => StepsMap.singleton (steps, bVar)
                      | SOME sm => StepsMap.insert (sm, steps, bVar))
                     )
            in
               List.foldl insertSteps fp newStepsLeafList
            end

         val (tVarMap,sm) = TVarMap.remove (tVarMap,oldVar)
         val stepsBVar = StepsMap.listItemsi sm
      in
         (List.foldl addSteps (tVarMap,fieldMap) stepsBVar, !expandInfo)     
      end

   fun getFlag ((varM, fieldM), (steps, LeafVar v)) =
      StepsMap.lookup (TVarMap.lookup(varM,v), steps)
     | getFlag ((varM, fieldM), (steps, LeafField f)) =
      StepsMap.lookup (SymMap.lookup(fieldM,f), steps)

   fun findField (bVars, (varMap, symMap)) =
      let
         val resRef = ref (NONE : FieldInfo.symid option)
         fun findVar field (_,bVar) =
            if BD.member (bVars,bVar) then resRef := SOME field else ()
         fun findField (field,sm) = StepsMap.appi (findVar field) sm
         val _ = SymMap.appi findField symMap
      in
         !resRef
      end

end


structure TypeTable : sig

   type table
   
   (*a type variable was not found in the type table*)
   exception TypeTableError

   val emptyTable : unit -> table

   val toStringSI : SymbolTable.symid list * TVar.tvar list * table * TVar.varmap -> string * TVar.varmap
   val dumpTableSI : table * TVar.varmap -> string * TVar.varmap
   
   val getSizes : table -> SizeConstraint.size_constraint_set
   val getFlow : table -> BooleanDomain.bfun
   
   val modifySizes : (SizeConstraint.size_constraint_set ->
                     SizeConstraint.size_constraint_set) * table -> table
   val modifyFlow : (BooleanDomain.bfun -> BooleanDomain.bfun) * table -> table

   val newType : Types.texp * table -> TVar.tvar
   
   (* Add the given symbol as having the given type. The other domains remain
   unaltered. *)
   val addSymbol : SymbolTable.symid * Types.texp * table -> TVar.tvar              
   
   (* Remove a symbol and all information from other domains regarding this symbol. *)
   val delSymbol : SymbolTable.symid * table -> TVar.set

   (* Remove the given symbol from the map and returns its type expression.
      The other domains remain unaltered so that (parts of) the type
      can be re-added using addSymbol. *)
   val getSymbol : SymbolTable.symid * table -> Types.texp

   (* Merely extract the type of the symbol without removing the symbol or the
   constraints of the type. *)
   val peekSymbol : SymbolTable.symid * table -> Types.texp
   
   val equateSymbols : SymbolTable.symid * SymbolTable.symid * table -> unit
   val equateSymbolsFlow : SymbolTable.symid * SymbolTable.symid * table -> unit
   val instantiateSymbol : SymbolTable.symid * SymSet.set * SymbolTable.symid * table -> unit

   val symbolsWithVars : TVar.set * table -> SymSet.set
   
   val affectedField : BooleanDomain.bvarset * table -> FieldInfo.symid option
   
   val sane : table -> unit

   val aVar : TVar.tvar
   val bVar : TVar.tvar
   val cVar : TVar.tvar
   val dVar : TVar.tvar
   val eVar : TVar.tvar
   val fVar : TVar.tvar

   val test : unit -> unit

end = struct

   val verbose = false
   val unifyVerbose = false
   val runSane = false

   type index = TVar.tvar

   structure HT = HashTable
   structure DA = DynamicArray
   structure S = Substitutions
   structure BD = BooleanDomain
   structure SC = SizeConstraint
   structure IS = IntBinarySet

   open Types
   
   datatype typeterm
      (* a function taking at least one argument *)
    = TT_FUN of (index list * index)
      (* a type synoym with its expanded type *)
    | TT_SYN of (TypeInfo.symid * index)
      (* an whole number *)
    | TT_ZENO
      (* a floating point number *)
    | TT_FLOAT
      (* a character sequence *)
    | TT_STRING
      (* a value containing no information *)
    | TT_UNIT
      (* a bit vector of a fixed size *)
    | TT_VEC of index
      (* a Herbrand constant, can only occur as the argument of VEC *)
    | TT_CONST of int
      (* an algebraic data type with a list of type arguments *)
    | TT_ALG of (TypeInfo.symid * index list)
      (* a record containing the given field and possible other fields that
         are determined by the last index that points to more TT_RECORDs *)
    | TT_RECORD of FieldInfo.symid * index  * index
      (* the state monad: return value, input state, output state *)
    | TT_MONAD of index * index * index
 
   fun sym_hash s = Word.fromInt (SymbolTable.toInt s)

   fun hash_list [] = Word.fromInt 0
     | hash_list (x :: xs) = Word.fromInt 7*x + Word.fromInt 3*hash_list xs
     
   fun typeterm_hash (TT_FUN (is,i)) = hash_list (Word.fromInt 4234::TVar.hash i::map TVar.hash is)
     | typeterm_hash (TT_SYN (s,i)) = hash_list [sym_hash s,TVar.hash i]
     | typeterm_hash (TT_ZENO) = Word.fromInt 29834
     | typeterm_hash (TT_FLOAT) = Word.fromInt 9845
     | typeterm_hash (TT_STRING) = Word.fromInt 394208
     | typeterm_hash (TT_UNIT) = Word.fromInt 9823
     | typeterm_hash (TT_VEC v) = hash_list [Word.fromInt 98028,TVar.hash v]
     | typeterm_hash (TT_CONST i) = Word.fromInt 9823*Word.fromInt i+Word.fromInt 2834
     | typeterm_hash (TT_ALG (s,is)) = hash_list (sym_hash s :: map TVar.hash is)
     | typeterm_hash (TT_RECORD (f,ft,i)) = hash_list [sym_hash f,TVar.hash ft, TVar.hash i]
     | typeterm_hash (TT_MONAD (i1,i2,i3)) = Word.fromInt 5345+hash_list [TVar.hash i1,TVar.hash i2, TVar.hash i3]

   (* structural equality, records with the same set of fields are different
   under this order *)
   fun typeterm_eq (TT_FUN (is1,i1),TT_FUN (is2,i2)) =
      ListPair.allEq TVar.eq (is1,is2) andalso TVar.eq (i1,i2)
     | typeterm_eq (TT_SYN (s1,i1),TT_SYN (s2,i2)) =
      SymbolTable.eq_symid (s1,s2) andalso TVar.eq (i1,i2)
     | typeterm_eq (TT_ZENO, TT_ZENO) = true
     | typeterm_eq (TT_FLOAT, TT_FLOAT) = true
     | typeterm_eq (TT_STRING, TT_STRING) = true
     | typeterm_eq (TT_UNIT, TT_UNIT) = true
     | typeterm_eq (TT_VEC i1, TT_VEC i2) = TVar.eq (i1,i2)
     | typeterm_eq (TT_CONST c1,TT_CONST c2) = c1=c2
     | typeterm_eq (TT_ALG (s1,is1), TT_ALG (s2,is2)) =
      SymbolTable.eq_symid (s1,s2) andalso ListPair.allEq TVar.eq (is1,is2)
     | typeterm_eq (TT_RECORD (f1,ft1,i1), TT_RECORD (f2,ft2,i2)) =
      SymbolTable.eq_symid (f1,f2) andalso TVar.eq (ft1,ft2) andalso TVar.eq (i1,i2)
     | typeterm_eq (TT_MONAD (i1,i2,i3),TT_MONAD (j1,j2,j3)) =
      TVar.eq (i1,j1) andalso TVar.eq (i2,j2) andalso TVar.eq (i3,j3)
     | typeterm_eq _ = false

   fun showTypeTermSI (ty, showInfo) = let
      val siTab = ref showInfo
      fun sep s [] = ""
        | sep s [v] = v
        | sep s (v :: vs) = v ^ s ^ sep s vs
      fun sT (TT_FUN ([f1], f2)) =
            showVar f1 ^ " -> " ^ showVar f2
        | sT (TT_FUN (fs1, f2)) =
            "(" ^ sep ", " (List.map showVar fs1) ^ ") -> " ^ showVar f2
        | sT (TT_SYN (syn, t)) = 
            SymbolTable.getString(!SymbolTables.typeTable, syn) ^ " => " ^ showVar t
        | sT (TT_ZENO) = "int"
        | sT (TT_FLOAT) = "float"
        | sT (TT_STRING) = "string"
        | sT (TT_UNIT) = "()"
        | sT (TT_VEC t) = "|" ^ showVar t ^ "|"
        | sT (TT_CONST c) = Int.toString(c)
        | sT (TT_ALG (ty, l)) =
         let
            val conStr = SymbolTable.getString(!SymbolTables.typeTable, ty)
         in
            conStr ^ 
            (if List.null l then "" else ("[" ^ sep "," (List.map showVar l) ^ "]"))
         end
        | sT (TT_RECORD (f,ft,i)) = SymbolTable.getString(!SymbolTables.fieldTable, f) ^
            ": " ^ showVar ft ^ "; " ^ showVar i
        | sT (TT_MONAD (r,f,t)) = "S " ^ showVar r ^
           " <" ^ showVar f ^ " => " ^ showVar t ^ ">"
       and showVar var =
         let 
            val (str, newSiTab) = TVar.varToString (var, !siTab)
         in
            (siTab := newSiTab; str)
         end
   in
      (sT ty, !siTab) 
   end

   fun getVars (TT_FUN (fs1, f2)) = f2::fs1
     | getVars (TT_SYN (syn, t)) = [t]
     | getVars (TT_ZENO) = []
     | getVars (TT_FLOAT) = []
     | getVars (TT_STRING) = []
     | getVars (TT_UNIT) = []
     | getVars (TT_VEC t) = [t]
     | getVars (TT_CONST c) = []
     | getVars (TT_ALG (ty, l)) = l
     | getVars (TT_RECORD (f,ft,i)) = [ft,i]
     | getVars (TT_MONAD (r,f,t)) = [r,f,t]

   datatype typeinfo
      = TERM of typeterm
      | LEAF of SymSet.set
      | FORW of index
      | OCCURS

   type entry = {
      flow : Path.flowpoints,
      info : index
   }
      
   type table = {
      hashCons : (typeterm, index) HT.hash_table,
      symTable : (SymbolTable.symid,entry) HT.hash_table,
      typeTable : typeinfo DA.array,
      boolDom : BD.bfun ref,
      sizeDom : SC.size_constraint_set ref
   }

   exception CondensingError
   exception IndexError
   exception TypeTableError

   fun emptyTable () = {
      hashCons = HT.mkTable (typeterm_hash,typeterm_eq) (10000, CondensingError),
      symTable = HT.mkTable (sym_hash,SymbolTable.eq_symid) (100, IndexError),
      typeTable = DA.array (10000, LEAF SymSet.empty),
      boolDom = ref BD.empty,
      sizeDom = ref SC.empty
   } : table

   fun showSym (sym, { flow = fp, info = index },(str, si)) =
      let
         val symStr = SymbolTable.getString(!SymbolTables.varTable, sym)
         val (vStr,si) =  TVar.varToString (index,si)
         val (fpStr, si) = Path.toStringSI (fp, si)
         val out = "\nvar " ^ symStr ^ ": " ^ vStr ^ fpStr
      in
         (str ^ out, si)
      end

   fun showEntry (idx, TERM t, (str, si)) =
      let
         val (vStr,si) = TVar.varToString (TVar.fromIdx idx,si)
         val (tStr,si) = showTypeTermSI (t,si)
         val out = "\n" ^ vStr ^ " = " ^ tStr
      in
         (str ^ out, si)
      end
     | showEntry (idx, LEAF refs, (str, si)) =
      if SymSet.isEmpty refs then (str, si) else
      let
         val (vStr,si) = TVar.varToString (TVar.fromIdx idx,si)
         fun showSym (sym,(sep,str)) = (",", str ^ sep ^
             SymbolTable.getString(!SymbolTables.varTable, sym))
         val (_,rStr) = SymSet.foldl showSym ("","") refs
         val out = "\n" ^ vStr ^ " used in " ^ rStr
      in
         (str ^ out, si)
      end
     | showEntry (idx, FORW index, (str, si)) =
      let
         val (vStr,si) = TVar.varToString (TVar.fromIdx idx,si)
         val (vStr',si) =  TVar.varToString (index,si)
         val out = "\n" ^ vStr ^ " => " ^ vStr'
      in
         (str ^ out, si)
      end
     | showEntry (idx, OCCURS, (str, si)) = (str ^ "infinite type", si)

   fun dumpTableSI (table : table, si) =
      let
         val tt = (#typeTable table)
         val st = (#symTable table)
         val si = DA.foldli
            (fn (i,tt,si) =>
               if (case tt of LEAF refs => SymSet.isEmpty refs | _ => false)
               then si else #2 (TVar.varToString (TVar.fromIdx i,si))) si tt
         val (symStr, si) = HT.foldi showSym ("",si) st
         val (tVarStr, si) = DA.foldli showEntry ("",si) tt
         val (tVarStr, si) = showEntry (DA.bound tt, DA.sub (tt, DA.bound tt),(tVarStr,si))
         val bdRef = #boolDom table
         val bdStr = BD.showBFun (!bdRef)
         val scRef = #sizeDom table
         val (scStr, si) = SC.toStringSI (!scRef, NONE, si)
         
      in
         (symStr ^ tVarStr ^ "\n" ^ bdStr ^ "\n" ^ scStr ^ "\n", si)
      end

   fun showTableSI (table : table, todo, done, si) =
      let
         val tt = #typeTable table
         fun printFixpoint ((str, si), [],  done) = (str,done,si)
           | printFixpoint ((str, si), var::vars, done) =
            if TVar.member (done,var)
            then
               printFixpoint ((str, si), vars, done)
            else
               let
                  val newVars = case DA.sub (tt, TVar.toIdx var) of TERM t => getVars t
                                                     | _ => []
               in
                  printFixpoint (showEntry (TVar.toIdx var, DA.sub (tt,TVar.toIdx var), (str,si)), vars @ newVars, TVar.add (var,done))
               end
      in
         printFixpoint (("", si), todo, done)
      end
      
   fun toStringSI (syms,vars,table : table,si) =
      let
         val st = #symTable table
         fun showSymbol (sym,(str,tVars,si)) =
            let
               val {flow=fp,info=i} = HT.lookup st sym
               val (str, si) = showSym (sym, {flow=fp,info=i}, (str,si))
               val (tabStr,tVars,si) =
                  showTableSI (table, i :: Path.varsOfFlowpoints fp, tVars, si)
            in
               (str ^ tabStr,tVars,si)
            end
         val resVars = showTableSI (table,vars,TVar.empty,si)
         val (sStr, tVars, si) = List.foldl showSymbol resVars syms
      in
         (sStr, si)
      end

   fun getSizes (table : table) = !(#sizeDom table)
   fun getFlow (table : table) = !(#boolDom table) 
   
   fun modifySizes (scFun, table : table) =
      ((#sizeDom table) := scFun (!(#sizeDom table)); table)
   fun modifyFlow (bFun, table : table) =
      ((#boolDom table) := bFun (!(#boolDom table)); table)

   fun ttFind (tt,v) =
      let
         fun resolve (v,v') = case DA.sub (tt,TVar.toIdx v') of
            FORW v'' => (DA.update (tt,TVar.toIdx v,FORW v''); resolve (v',v''))
          | _ => v'
      in
         case DA.sub (tt,TVar.toIdx v) of
            FORW v' => resolve (v,v')
          | _ => v
      end
   
   fun ttGet (tt,v) = DA.sub (tt,TVar.toIdx (ttFind (tt,v)))
   fun ttSet (tt,v,ty) = DA.update (tt,TVar.toIdx (ttFind (tt,v)),ty)
   fun ttGetVars tt =
      let
         fun getVar (idx,FORW _,set) = set
           | getVar (idx,LEAF ss,set) = if SymSet.isEmpty ss then set else
               TVar.fromIdx idx :: set
           | getVar (idx,_,set) = TVar.fromIdx idx :: set
      in
         DA.foldri getVar [] tt
      end

   fun allocType (t,table : table) =
      let
         val tt = #typeTable table
         val hc = #hashCons table
      in
         case HT.find hc t of
            SOME idx => idx
          | NONE =>
            let
               val idx = TVar.freshTVar ()
               val _ = HT.insert hc (t, idx)
               val _ = DA.update (tt, TVar.toIdx idx, TERM t)
            in
               idx
            end
      end

   fun sane (table : table) = if not runSane then () else
      let
         val tt = #typeTable table
         val st = #symTable table
         val siRef = ref TVar.emptyShowInfo
         fun err (str,syms,vars) =
            let
               val si = !siRef
               val (symsStr,_) = foldl (fn (sym,(str,sep)) => (str ^ sep ^ SymbolTable.getString(!SymbolTables.varTable, sym), ", ")) ("","") syms
               val (varsStr,si,_) = foldl (fn (var,(str,si,sep)) => let val (vStr,si) = TVar.varToString (var,si) in (str ^ sep ^ vStr, si, ", ") end) ("",si,"") vars
               val (sStr,si) = toStringSI (syms, vars, table, si)
               val _ = siRef := si
               val _ = TextIO.print ("\nINVARIANT ERROR: " ^ str ^ ": " ^ symsStr ^ "; " ^ varsStr ^ ":" ^ sStr ^ "\n")

            in
               raise IndexError
            end
         fun checkSym (sym,{flow = fp, info = idx}) =
               List.app (fn var => case ttGet(tt,var) of
                  LEAF symSet => if SymSet.member (symSet,sym) then () else
                     err ("no reference from type variable to symbol" , [sym], [idx,var])
                | TERM t => err ("flow information does not relate to type variable", [sym], [idx,var])
                | FORW _ => err ("variable in flow information not replaced", [sym], [idx,var])
                | OCCURS => (TextIO.print "an occurs placeholder has not been removed\n"; raise IndexError)
               ) (Path.varsOfFlowpoints fp)
         val _ = HT.appi checkSym st
         fun checkVar (idx, LEAF symSet) =
               List.app (fn sym => case HT.find st sym of
                  NONE => err ("symbol referenced in variable not in symbol", [sym], [TVar.fromIdx idx])
                | SOME {flow = fp, info = tvar} =>
                  if List.exists (fn v => TVar.toIdx v=idx) (Path.varsOfFlowpoints fp) then () else
                     err ("no reference from symbol to type variable", [sym], [TVar.fromIdx idx,tvar])
               ) (SymSet.listItems symSet)
           | checkVar (idx, TERM (TT_RECORD (_,_,rowVar))) =
            (case ttGet (tt,rowVar) of
                 LEAF symSet => ()
               | TERM (TT_RECORD _) => ()
               | TERM _ => err ("row variable is a type", [], [TVar.fromIdx idx,rowVar])
               | FORW _ => raise IndexError
               | OCCURS => (TextIO.print "an occurs placeholder has not been removed\n"; raise IndexError)

            )
           | checkVar (idx, _) = ()
         val _ = if DA.bound tt<=1 then () else DA.appi checkVar tt
               (*handle IndexError => (TextIO.print ("sane: table broken at index " ^ #1 (TVar.varToString (TVar.fromIdx (DA.bound tt),TVar.emptyShowInfo)) ^ "\n"); TextIO.print (#1 (dumpTableSI (table, TVar.emptyShowInfo))); raise IndexError)*)
      in 
         ()
      end

   fun newType (ty,table : table) =
      let
         val tt = #typeTable table
         val allocType = fn t => allocType (t,table)
         fun conv (FUN (ts, t)) = allocType (TT_FUN (List.map conv ts, conv t))
           | conv (SYN (syn, t)) = allocType (TT_SYN (syn, conv t))
           | conv (ZENO) = allocType TT_ZENO
           | conv (FLOAT) = allocType TT_FLOAT
           | conv (STRING) = allocType TT_STRING
           | conv (UNIT) = allocType TT_UNIT
           | conv (VEC t) = allocType (TT_VEC (conv t))
           | conv (CONST c) = allocType (TT_CONST c)
           | conv (ALG (sym, l)) = allocType (TT_ALG (sym, List.map conv l))
           | conv (RECORD (i,e,[])) = convV i
           | conv (RECORD (i,e,RField { name = f, fty = ft, exists} :: fs)) =
               allocType (TT_RECORD (f, conv ft, conv (RECORD (i,e,fs))))
           | conv (MONAD (r,f,t)) = allocType (TT_MONAD (conv r, conv f, conv t))
           | conv (VAR (v,_)) = convV v
          and convV v = case ttGet (tt, v) of
                 (LEAF _) => v
               | _ => raise IndexError
         val _ = sane (table)
      in
         conv ty
      end

   fun addSymbol (sym,ty,table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("addSymbol " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " with type " ^ #1 (showTypeSI (ty,TVar.emptyShowInfo)) ^ "\n")
         val idx = newType (ty,table)
         val fp = Path.typeToFlowpoints ty
         val st = #symTable (table : table)
         fun addRef (LEAF syms) = LEAF (SymSet.add (syms,sym))
           | addRef _ = raise IndexError
         val tt = #typeTable table
         fun updateRef idx = ttSet (tt, idx, addRef (ttGet (tt, idx)))
         val _ = List.app updateRef (Path.varsOfFlowpoints fp)
         val _ = if HT.inDomain st sym then
            (TextIO.print ("addSymbol: error, previous type for " ^
               SymbolTable.getString(!SymbolTables.varTable, sym) ^ " exists with " ^
                #1 (toStringSI ([sym], [#info (HT.lookup st sym)], table, TVar.emptyShowInfo)) ^ "\n");
             raise IndexError) else ()
         val _ = HT.insert st (sym,{ flow = fp, info = idx })
         val _ = sane (table)
      in
        idx
      end

   fun delSymbol (sym,table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("delSymbol " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ "\n")
         val st = #symTable (table : table)
         val { flow = fp, info } = HT.remove st sym
            handle IndexError => (TextIO.print ("delSymbol: " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " not mapped.\n"); raise TypeTableError)
         val unusedTVars = ref TVar.empty
         fun delRef (v,LEAF syms) =
            let
               val newSet = SymSet.delete (syms,sym)
               val _ = if SymSet.isEmpty newSet then
                  unusedTVars := TVar.add (v,!unusedTVars) else ()
            in
               LEAF newSet
            end
           | delRef _ = raise IndexError
         val tt = #typeTable table
         fun updateRef v = ttSet (tt, v, delRef (v, ttGet (tt, v)))
         val tVars = Path.varsOfFlowpoints fp
         val _ = List.app updateRef tVars
         val bdRef = #boolDom table
         val bVarsToKill = foldl BD.addToSet BD.emptySet (map #2 (Path.flagsOfFlowpoints fp))
         val _ = bdRef := BD.projectOut (bVarsToKill, !bdRef)
         val _ = sane (table)
      in
         !unusedTVars
      end

   (* turn a type of a symbol into a ADT type; returns the set of indices
      at which variables of this type lie so that their symbol set can be
      altered *)
   fun termToType ({ flow = fp, info = idx }, table : table) =
      let
         val varsRef = ref IS.empty
         val occursRef = ref NONE : TVar.tvar option ref
         val tt = #typeTable table
         fun downFrom (n,s,[]) = []
           | downFrom (n,s,v::vs) = gT (Path.appendIntStep n s,v) :: downFrom (n-1,s,vs)
         and gT (s,idx) =
            let
               val idx = ttFind (tt,idx)
               val ty = ttGet (tt,idx) 
               val _ = ttSet (tt,idx,OCCURS)
               val res = case ty of
                   TERM (TT_FUN (fs1, f2)) => FUN (downFrom (~1,s,fs1), gT (Path.appendIntStep 0 s,f2) )
                 | TERM (TT_SYN (syn, t)) => SYN (syn, gT (s,t))
                 | TERM (TT_ZENO) => ZENO
                 | TERM (TT_FLOAT) => FLOAT
                 | TERM (TT_STRING) => STRING
                 | TERM (TT_UNIT) => UNIT
                 | TERM (TT_VEC t) => VEC (gT (s,t))
                 | TERM (TT_CONST c) => CONST c
                 | TERM (TT_ALG (sym, vs)) => ALG (sym, downFrom (length vs,s,vs))
                 | TERM (TT_RECORD (f,ft,i)) =>
                  let
                     val fType = gT (Path.appendFieldStep f s,ft)
                     val fBVar = Path.getFlag (fp,(s,Path.mkFieldLeaf f))
                        handle NotFound => (TextIO.print ("cannot find path " ^ #1 (Path.toStringSI (Path.createFlowpoints [(s,Path.mkFieldLeaf f)],TVar.emptyShowInfo)) ^ "\nin" ^ #1 (Path.toStringSI (fp,TVar.emptyShowInfo)) ^ "\n" ^ #1 (dumpTableSI (table,TVar.emptyShowInfo))); raise IndexError)
                     val rf = RField { name = f, fty = fType, exists = fBVar }
                     fun insert (r1 as RField { name = f1, ...})
                                ((r2 as RField { name = f2, ...}) :: rfs) =
                        (case SymbolTable.compare_symid (f1,f2) of
                           EQUAL => raise IndexError
                         | LESS => r1 :: r2 :: rfs
                         | GREATER => r2 :: insert r1 rfs
                        )
                       | insert r1 [] = [r1]
                  in
                     case gT (s,i) of
                          RECORD (tVar,bVar,fs) => RECORD (tVar,bVar,insert rf fs)
                        | VAR (tVar,bVar) => RECORD (tVar,bVar,[rf])
                        | _ =>  (TextIO.print ("expected row variable in " ^ #1 (TVar.varToString (idx,TVar.emptyShowInfo)) ^ "\n" ^ #1 (dumpTableSI (table, TVar.emptyShowInfo)) ^ "\n"); raise IndexError)
                  end
                 | TERM (TT_MONAD (res,inp,out)) => MONAD (
                     gT (Path.appendIntStep 0 s,res),
                     gT (Path.appendIntStep (~1) s,inp),
                     gT (Path.appendIntStep 1 s,out))
                 | LEAF symSet =>
                     let
                        val _ = varsRef := IS.add (!varsRef,TVar.toIdx idx)
                        val bVar = Path.getFlag (fp,(s,Path.mkVarLeaf idx))
                           handle NotFound => raise IndexError
                     in
                        VAR (idx,bVar)
                     end
                 | OCCURS => (occursRef := SOME idx; VAR (idx,BD.freshBVar ()))
                 | _ => raise IndexError
               
               val _ = ttSet (tt,idx,ty)
               val _ = case (ty,!occursRef) of
                    (OCCURS,_) => ()
                  | (_,NONE) => ()
                  | (_,SOME occursIdx) => if TVar.eq (occursIdx,idx) then
                     let
                        val (vStr,si) = TVar.varToString (idx,TVar.emptyShowInfo)
                        val (tStr,si) = showTypeSI (res,si)
                     in
                         raise S.UnificationFailure (S.OccursCheck,
                           "infinite type " ^ vStr ^ " = " ^ tStr ^ " not allowed"
                         )
                     end
                     else ()

            in
               res
            end
         val ty = gT (Path.emptySteps, idx)
      in
         (ty, !varsRef)
      end

   fun termToSteps (index,table : table) =
      let
         val tt = #typeTable table
         fun downFrom num [] = []
           | downFrom num (i :: is) =
               List.map (Path.prependIntStep num) i @ downFrom (num-1) is
         fun fromType v =
            let
               val v = ttFind (tt,v)
               val ty = ttGet (tt,v)
               val _ = ttSet (tt,v,OCCURS)
               val paths = case ty of
                  TERM term => fromTerm term
                | LEAF _ => [(Path.emptySteps, Path.mkVarLeaf v)]
                | OCCURS => []
                | _ => raise IndexError
               val _ = ttSet (tt,v,ty)
            in
               paths
            end
         and fromTerm (TT_FUN (is,res)) = downFrom 0 (List.map fromType (res::is))
           | fromTerm (TT_SYN (_,index)) = fromType index
           | fromTerm (TT_ZENO) = []
           | fromTerm (TT_FLOAT) = []
           | fromTerm (TT_STRING) = []
           | fromTerm (TT_UNIT) = []
           | fromTerm (TT_VEC index) =  fromType index
           | fromTerm (TT_CONST _) = []
           | fromTerm (TT_ALG (_, is)) = downFrom (length is) (List.map fromType is)
           | fromTerm (TT_RECORD (f,ft,i)) = (Path.emptySteps, Path.mkFieldLeaf f) ::
            List.map (Path.prependFieldStep f) (fromType ft) @ fromType i
           | fromTerm (TT_MONAD (res,inp,out)) =
            List.map (Path.prependIntStep 0) (fromType res) @
            List.map (Path.prependIntStep (~1)) (fromType inp) @
            List.map (Path.prependIntStep 1) (fromType out)
      in
         fromType index
      end

   fun getSymbol (sym,table : table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("getSymbol " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ "\n")
         val tt = #typeTable table
         val st = #symTable table
         val ti = HT.remove st sym
            handle IndexError => (TextIO.print ("getSymbol: " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " not mapped.\n"); raise TypeTableError)
         val (ty,vars) = termToType (ti,table)
         val _ = IS.app (fn idx => case ttGet(tt,TVar.fromIdx idx) of
               LEAF symSet => ttSet (tt,TVar.fromIdx idx,LEAF (SymSet.delete (symSet,sym)))
             | _ => raise IndexError
             ) vars
         val _ = sane (table)
      in
         ty
      end
   
   fun peekSymbol (sym,table : table) =
      let
         val st = #symTable table
         val ti = HT.lookup st sym
            handle IndexError => (TextIO.print ("peekSymbol: " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " not mapped.\n"); raise TypeTableError)
         val (ty,vars) = termToType (ti,table)
      in
         ty
      end

   fun unify (v1,v2, table : table) =
      let
         val tt = #typeTable table
         val st = #symTable table
         fun fixpoint [] = ()
           | fixpoint ((v1,v2) :: pairs) =
            let

               fun pairToString ((v1,v2),(str,sep,si)) =
                  let
                     val (v1Str,si) = TVar.varToString (v1,si)
                     val (v2Str,si) = TVar.varToString (v2,si)
                  in
                     (str ^ sep ^ "(" ^ v1Str ^ "," ^ v2Str ^ ")", ", ", si)
                  end
               val (pStr,_,si) = foldl pairToString ("","",TVar.emptyShowInfo) ((v1,v2) :: pairs)
               (*val _ = TextIO.print ("unifying " ^ pStr ^ "\n")*)
               val _  = sane (table)

               val v1 = ttFind (tt,v1)
               val v2 = ttFind (tt,v2)
               val pairs = if TVar.eq (v1,v2) then pairs else
                  case unifyTT (v1, v2, ttGet (tt,v1), ttGet (tt,v2)) of
                     [] => pairs
                   | newPairs => newPairs @ pairs
            in
               fixpoint pairs
            end
         and unifyTT (v1, v2, LEAF symSet1, LEAF symSet2) =
               let
                  val _ = if not unifyVerbose then () else TextIO.print ("unifying LEAFs\n")
                  val symSet12 = SymSet.union (symSet1,symSet2)
                  val (vGood,sGood,vBad,sBad) =
                     if TVar.toIdx v1<TVar.toIdx v2 then
                        (v1,symSet1,v2,symSet2) else (v2,symSet2,v1,symSet1)
                  val _ = ttSet (tt,vBad, FORW vGood)
                  val _ = ttSet (tt,vGood, LEAF symSet12)
                  val _ = updateFlow (vBad,sBad,[(Path.emptySteps, Path.mkVarLeaf vGood)])
                  val scRef = #sizeDom table
                  val _ = scRef := SC.rename (vBad,vGood,!scRef)
               in
                  []
               end
           | unifyTT (v1, v2, TERM t1, TERM t2) = (if not unifyVerbose then () else TextIO.print ("unifying TERM/TERM " ^ #1 (showTypeTermSI (t1,TVar.emptyShowInfo)) ^ "="  ^ #1 (showTypeTermSI (t2,TVar.emptyShowInfo)) ^ "\n"); genPairs (v1,v2, t1,t2))
           | unifyTT (v1, v2, LEAF symSet, TERM t2) = substVar (v1,symSet,v2,t2)
           | unifyTT (v1, v2, TERM t1, LEAF symSet) = substVar (v2,symSet,v1,t1)
           | unifyTT _ = raise TypeTableError
      and genPairs (v1,v2,TT_FUN (f1, f2), TT_FUN (g1, g2)) = if List.length f1<>List.length g1
         then raise S.UnificationFailure (S.Clash, 
               "function with different number of arguments (" ^
               Int.toString (List.length f1) ^ " and " ^
               Int.toString (List.length g1) ^ ")"
            )
         else (f2,g2)::ListPair.zip (f1,g1)
        | genPairs (_ ,v2,TT_SYN (_,v1),t2) = unifyTT (ttFind (tt,v1), v2, ttGet (tt,v1), TERM t2)
        | genPairs (v1,_ ,t1,TT_SYN (_,v2)) = unifyTT (v1, ttFind (tt,v2), TERM t1, ttGet (tt, v2))
        | genPairs (v1,v2,TT_ZENO, TT_ZENO) = []
        | genPairs (v1,v2,TT_FLOAT, TT_FLOAT) = []
        | genPairs (v1,v2,TT_STRING, TT_STRING) = []
        | genPairs (v1,v2,TT_UNIT, TT_UNIT) = []
        | genPairs (v1,v2,TT_VEC t1, TT_VEC t2) = [(t1, t2)]
        | genPairs (v1,v2,TT_CONST c1, TT_CONST c2) =
           if c1=c2 then [] else raise S.UnificationFailure (S.Clash,
            "incompatible bit vectors sizes (" ^ Int.toString c1 ^ " and " ^
            Int.toString c2 ^ ")")
        | genPairs (v1,v2,TT_RECORD r1, TT_RECORD r2) =
         let
            (*val _ = TextIO.print ("record unificaiton:\n" ^ #1 (dumpTableSI (table,TVar.emptyShowInfo)) ^ "\n")*)
            fun gatherFields sm (f,ft,i) = case ttGet (tt,i) of
                 LEAF symSet => (SymMap.insert (sm,f,ft), ttFind (tt,i), symSet)
               | TERM (TT_RECORD r) => gatherFields (SymMap.insert (sm,f,ft)) r
               | _ => raise IndexError
            val (fs1,row1,symSet1) = gatherFields SymMap.empty r1
            val (fs2,row2,symSet2) = gatherFields SymMap.empty r2

            val newIn1 = ref ([] : (FieldInfo.symid * index) list)
            val newIn2 = ref ([] : (FieldInfo.symid * index) list)
            val rPairs = ref ([] : (index * index) list)
            fun addRef (f, SOME fIdx1, SOME fIdx2) =
               (rPairs := (fIdx1,fIdx2) :: !rPairs; NONE)
              | addRef (f, SOME fIdx1, NONE) =
               (newIn2 := (f, fIdx1) :: !newIn2; NONE)
              | addRef (f, NONE, SOME fIdx2) =
               (newIn1 := (f, fIdx2) :: !newIn1; NONE)
              | addRef _ = raise IndexError
            val _ = SymMap.mergeWithi addRef (fs1,fs2)

            fun addField ((f,ft),row) =
               let
                  val newRow = TVar.freshTVar ()
                  val _ = ttSet (tt,row,TERM (TT_RECORD (f,ft,newRow)))
               in
                  newRow
               end
            val newRow1 = foldl addField row1 (!newIn1)
            val newRow2 = foldl addField row2 (!newIn2)
            
            fun genPath (f,fIdx) = (Path.emptySteps, Path.mkFieldLeaf f) ::
               List.map (Path.prependFieldStep f) (termToSteps (fIdx, table))
            val newPaths1 = (Path.emptySteps, Path.mkVarLeaf newRow1) ::
                            List.concat (List.map genPath (!newIn1))
            val newPaths2 = (Path.emptySteps, Path.mkVarLeaf newRow2) ::
                            List.concat (List.map genPath (!newIn2))
            val _ = updateFlow (row1,symSet1,newPaths1)
            val _ = updateFlow (row2,symSet2,newPaths2)
         in
            (newRow1,newRow2) :: !rPairs
         end
        | genPairs (v1,v2,TT_MONAD (r1,f1,t1), TT_MONAD (r2,f2,t2)) =
            [(r1, r2), (f1, f2), (t1, t2)]
        | genPairs (v1,v2,TT_ALG (ty1, l1), TT_ALG (ty2, l2)) =
         let 
            fun incompat () = raise S.UnificationFailure (S.Clash,
               "cannot match constructor " ^
               SymbolTable.getString(!SymbolTables.typeTable, ty1) ^
               " with " ^
               SymbolTable.getString(!SymbolTables.typeTable, ty2))
         in case SymbolTable.compare_symid (ty1, ty2) of
           LESS => incompat ()
         | GREATER => incompat ()
         | EQAL => ListPair.zipEq (l1,l2)
         end
        | genPairs (v1,v2,t1,t2) =
         let
            fun descr (TT_FUN _) = "a function type"
              | descr (TT_ZENO) = "int"
              | descr (TT_FLOAT) = "float"
              | descr (TT_STRING) = "string"
              | descr (TT_UNIT) = "()"
              | descr (TT_VEC t) = (case ttGet (tt,t) of
                 TERM (TT_CONST c) => "a vector of " ^ Int.toString c ^ " bits"
               | _ => "a bit vector"
              )
              | descr (TT_ALG (ty, _)) = "type " ^
                  SymbolTable.getString(!SymbolTables.typeTable, ty)
              | descr (TT_RECORD r) =
               let
                  fun gatherFields (f,ft,i) =
                     case ttGet (tt,i) of
                          TERM (TT_RECORD r) => SymSet.add (gatherFields r,f)
                        | LEAF _ => SymSet.empty
                        | _ => raise IndexError
                  val fs = gatherFields r
                  fun showField (f,str) =
                     SymbolTable.getString(!SymbolTables.fieldTable, f) ^
                     ", " ^ str
               in
                  "a record {" ^ SymSet.foldr showField "..." fs ^ "}"
               end
              | descr (TT_MONAD _) = "an action"
              | descr _ = "something that shouldn't be here"
         in
            raise S.UnificationFailure (S.Clash, "cannot match " ^ descr t1 ^
                                        " against " ^ descr t2)
         end
      and substVar (vVar,symSet,rVar,termType) = 
         let
            val _ = if not unifyVerbose then () else TextIO.print ("unifying LEAF/TERM " ^ #1 (TVar.varToString (vVar,TVar.emptyShowInfo)) ^ "=" ^ #1 (showTypeTermSI (termType,TVar.emptyShowInfo)) ^ "\n")
            val _ = if TVar.toIdx vVar>TVar.toIdx rVar then
                  (ttSet (tt, vVar, FORW rVar); ttSet (tt, rVar, TERM termType))
               else
                  (ttSet (tt, rVar, FORW vVar); ttSet (tt, vVar, TERM termType))

            val stepsLeafList = termToSteps (rVar,table)
            val _ = updateFlow (vVar,symSet,stepsLeafList)

            fun getVarInLeaf ((_,leaf),set) = case Path.getVarLeaf leaf of
                 NONE => set
               | SOME var => IS.add (set,TVar.toIdx var)
            val targetVars = foldl getVarInLeaf IS.empty stepsLeafList
            fun updateRef idx = case ttGet(tt,TVar.fromIdx idx) of
                 LEAF symSetVar => ttSet (tt,TVar.fromIdx idx,LEAF (SymSet.union (symSet, symSetVar)))
               | _ => raise IndexError
            val _ = IS.app updateRef targetVars

            val scRef = (#sizeDom table)
            val newPairs = case termType of
                  TT_CONST n => (case SC.add (SC.equality (vVar,[],n), !scRef) of
                      SC.RESULT (newConsts,sCons) => (scRef := sCons;
                         List.map (fn (v,c) => (v, newType (CONST c,table))) newConsts
                         )
                     | SC.UNSATISFIABLE => raise S.UnificationFailure (S.Clash,
                        "size constraints over vectors are unsatisfiable")
                     | SC.FRACTIONAL => raise S.UnificationFailure (S.Clash,
                        "solution to size constraint is not integral")
                     | SC.NEGATIVE => raise S.UnificationFailure (S.Clash,
                        "constraint implies that vector has non-positive size")
                    )
               | _ => []
         in                              
            newPairs
         end
      (* When a variable vVar is replaced by a type that has the paths in stepsLeafList,
         this function updates the flow and reverse information. *)
      and updateFlow (vVar,symSet,[([], leaf)]) = (case Path.getVarLeaf leaf of
             NONE => raise IndexError
           | SOME rVar => if TVar.eq (vVar,rVar) then () else
            let
               fun update sym =
                  let
                     val { flow = fp, info = idx } = HT.lookup st sym
                        handle IndexError => (if not unifyVerbose then () else TextIO.print ("updateFlow: " ^ SymbolTable.getString(!SymbolTables.varTable, sym) ^ " not mapped.\n"); raise TypeTableError)

                     val (vBadStr, si) = TVar.varToString (vVar, TVar.emptyShowInfo)
                     val (vGoodStr, si) = TVar.varToString (rVar, si)
                     val (fpStr, si) = Path.toStringSI (fp,si)
                     (*val _ = TextIO.print ("renaming " ^ vBadStr ^ " to " ^ vGoodStr ^ " in " ^ fpStr ^ "\n")*)

                     val fp = Path.renameVariable (vVar,rVar,fp)
                     val _ = HT.insert st (sym, {flow = fp, info = idx})
                  in
                     ()
                  end
               val _ = SymSet.app update symSet
            in
               ()
            end
          )
        | updateFlow (vVar,symSet,stepsLeafList) =
         let
            val (vStr,si) = TVar.varToString (vVar,TVar.emptyShowInfo)
            val (pStr,si) = Path.toStringSI (Path.createFlowpoints stepsLeafList, si)
            val _ = if not verbose then () else
               TextIO.print ("FLOW: update " ^ vStr ^  " with" ^ pStr ^ "\n")
            fun updateNewLeaf (_,leaf) = case Path.getVarLeaf leaf of
                  NONE => ()
                | SOME v => (case ttGet (tt,v) of
                   LEAF ss => ttSet  (tt, v,LEAF (SymSet.union (ss,symSet)))
                 | _ => raise IndexError
                )
            val _ = List.app updateNewLeaf stepsLeafList
            fun getExpandInfoForSym sym =
               let
                  val { flow = fp, info = index } = HT.lookup st sym
                  val (fp, expandInfo) = Path.insertSteps (fp,vVar,stepsLeafList)
                  val _ = HT.insert st (sym, { flow = fp, info = index })
               in
                  expandInfo
               end
            val expandInfo = List.concat (List.map getExpandInfoForSym (SymSet.listItems symSet))
            val varsToExpand = List.map #1 expandInfo
            val vectorsToExpandTo = List.map #2 expandInfo 
            fun transpose [] = []
              | transpose ([]::_) = []
              | transpose rows = (map hd rows) :: (transpose (map tl rows))
            val vectorsTransposed = transpose vectorsToExpandTo
            val contra = List.map (Path.stepsContra o #1) stepsLeafList
            val bdRef = (#boolDom table)
            fun doExpand [] =
               bdRef := BD.projectOut (List.foldl BD.addToSet BD.emptySet varsToExpand, !bdRef)
              | doExpand ((contra, vs) :: cvss) =
               (bdRef := BD.expand (varsToExpand, map (fn v => (contra, v)) vs, !bdRef);
               doExpand cvss)
            val _ = doExpand (ListPair.zip (contra, vectorsTransposed))
         in
            ()
         end

   in
      fixpoint [(v1,v2)]

   end
         
   fun equateSymbols (sym1,sym2,table : table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("equateSymbols " ^ SymbolTable.getString(!SymbolTables.varTable, sym1) ^ " and " ^ SymbolTable.getString(!SymbolTables.varTable, sym2) ^ "\n")
         val st = #symTable table
         val { info = idx1, ... } = HT.lookup st sym1
         val { info = idx2, ... } = HT.lookup st sym2
         val _ = unify (idx1,idx2,table)
         val { flow = fp1, ... } = HT.lookup st sym1
         val { flow = fp2, ... } = HT.lookup st sym2
         val bdRef = #boolDom table
         val flags = ListPair.zip (Path.flagsOfFlowpoints fp1, Path.flagsOfFlowpoints fp2)

         (*val (str,si) = toStringSI ([sym1,sym2],[],table,TVar.emptyShowInfo)
         val _ = TextIO.print ("equatSymbols: bool func = " ^ BD.showBFun (!bdRef) ^ str ^ "\n")
         val _ = TextIO.print (foldl (fn (((_,f1),(_,f2)),str) => BD.showVar f1 ^ "," ^ BD.showVar f2 ^ "; " ^ str) "" flags ^ "\n")*)

         val _ = List.app (fn ((_,f1),(_,f2)) => bdRef := BD.meetEqual (f1,f2,!bdRef)) flags
      in
         sane (table)
      end

   fun equateSymbolsFlow (sym1,sym2,table : table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("equateSymbolsFlow " ^ SymbolTable.getString(!SymbolTables.varTable, sym1) ^ " and " ^ SymbolTable.getString(!SymbolTables.varTable, sym2) ^ "\n")
         val st = #symTable table
         val { info = idx1, ... } = HT.lookup st sym1
         val { info = idx2, ... } = HT.lookup st sym2
         val _ = unify (idx1,idx2,table)
         val { flow = fp1, ... } = HT.lookup st sym1
         val { flow = fp2, ... } = HT.lookup st sym2
         val bdRef = #boolDom table
         val flags = ListPair.zip (Path.flagsOfFlowpoints fp1, Path.flagsOfFlowpoints fp2)
         val _ = List.app (fn ((contra,f1),(_,f2)) =>
            if contra then
               bdRef := BD.meetVarImpliesVar (f2,f1) (!bdRef)
            else
               bdRef := BD.meetVarImpliesVar (f1,f2) (!bdRef)) flags
      in
         sane (table)
      end

   fun instantiateSymbol (oldSym, args, newSym, table : table) =
      let
         val _ = if not verbose then () else
            TextIO.print ("instantiateSymbol " ^ SymbolTable.getString(!SymbolTables.varTable, oldSym) ^ "\n")
         val tt = #typeTable table
         val st = #symTable table
         val { flow = fp, info = idx } = HT.lookup st oldSym
         val candidates = Path.varsOfFlowpoints fp
         val symsToIgnore = SymSet.add (args,oldSym)
         fun notInEnv v = case ttGet(tt, v) of
              LEAF symSet => SymSet.isSubset (symSet,symsToIgnore)
            | _ => raise IndexError
         val instantiate = List.filter notInEnv candidates
         val subst = HT.mkTable (TVar.hash, TVar.eq) (List.length instantiate, IndexError)
         val _ = List.app (fn v => HT.insert subst (v,TVar.freshTVar ())) instantiate
         fun dup v = case ttGet(tt, v) of
             TERM t => allocType (dupTerm t, table)
           | LEAF symSet => (
            case HT.find subst (ttFind (tt,v)) of
               NONE => (ttSet (tt, v, LEAF (SymSet.add (symSet,newSym))); v)
             | SOME newV => (ttSet (tt, newV, LEAF (SymSet.singleton newSym)); newV)
           )
           | _ => raise IndexError
         and dupTerm (TT_FUN (fs1, f2)) = TT_FUN (map dup fs1, dup f2)
           | dupTerm (TT_SYN (syn, t)) = TT_SYN (syn, dup t)
           | dupTerm (TT_ZENO) = TT_ZENO
           | dupTerm (TT_FLOAT) = TT_FLOAT
           | dupTerm (TT_STRING) = TT_STRING
           | dupTerm (TT_UNIT) = TT_UNIT
           | dupTerm (TT_VEC t) = TT_VEC (dup t)
           | dupTerm (TT_CONST c) = TT_CONST c
           | dupTerm (TT_ALG (ty, l)) = TT_ALG (ty, map dup l)
           | dupTerm (TT_RECORD (f,ft,i)) = TT_RECORD (f, dup ft, dup i)
           | dupTerm (TT_MONAD (r,f,t)) = TT_MONAD (dup r, dup f, dup t)
         val newIdx = dup idx
         val newFp = Path.createFlowpoints (termToSteps (newIdx, table))
         val _ = HT.insert st (newSym,{ flow = newFp, info = newIdx })
         (* perform expansion on the Boolean flags of oldSym,args to
         newSym,args' where the flags of args' are fresh variables that need
         to be discarded after expansion *)
         val oldSymFlags = List.map #2 (Path.flagsOfFlowpoints fp)
         val newSymFlags = List.map (fn (_,f) => (false,f)) (Path.flagsOfFlowpoints newFp)
         
         val oldArgsFlags = List.map #2 (List.concat (List.map (
               Path.flagsOfFlowpoints o #flow o HT.lookup st
            ) (SymSet.listItems args)))
            handle IndexError => (TextIO.print (#1 (dumpTableSI (table,TVar.emptyShowInfo))); raise IndexError)
         val newArgsFlags = List.map (fn f => (false, BD.freshBVar ())) oldArgsFlags
         val bdRef = #boolDom table
         val _ = bdRef := BD.expand (oldSymFlags @ oldArgsFlags, newSymFlags @ newArgsFlags, !bdRef)
         val staleBVars = List.foldl BD.addToSet BD.emptySet (List.map #2 newArgsFlags)
         val _ = bdRef := BD.projectOut (staleBVars, !bdRef)
         
         val scRef = #sizeDom table
         val _ = scRef := SC.expand (subst,!scRef) 
      in
         sane (table)
      end

   fun affectedField (bVars, table : table) =
      HT.fold (fn (entry,res) => case res of
            SOME f => SOME f
          | NONE => Path.findField (bVars,#flow entry)
         ) NONE (#symTable table)

   fun symbolsWithVars (tVars, table : table) =
      let
         val tt = #typeTable table
         fun addSyms (tVar,ss) = case ttGet (tt,tVar) of
               LEAF symSet => SymSet.union (ss,symSet)
             | _ => ss
      in
         List.foldl addSyms SymSet.empty (TVar.listItems tVars)
      end


   val aVar = TVar.freshTVar ()      
   val bVar = TVar.freshTVar ()      
   val cVar = TVar.freshTVar ()      
   val dVar = TVar.freshTVar ()      
   val eVar = TVar.freshTVar ()      
   val fVar = TVar.freshTVar ()      


   fun test _ =
      let
         val table = emptyTable ()
         val st = !SymbolTables.varTable
         val st = SymbolTable.push st
         val (st,xVar) = SymbolTable.fresh (st, Atom.atom "x")
         val (st,yVar) = SymbolTable.fresh (st, Atom.atom "y")
         val (st,zVar) = SymbolTable.fresh (st, Atom.atom "z")
         val (st,yNewVar) = SymbolTable.fresh (st, Atom.atom "yNew")
         val _ = SymbolTables.varTable := st
         val ft = !SymbolTables.fieldTable
         val (ft,foo) = SymbolTable.fresh (ft, Atom.atom "foo")
         val (ft,bar) = SymbolTable.fresh (ft, Atom.atom "bar")
         val (ft,baz) = SymbolTable.fresh (ft, Atom.atom "baz")
         val (ft,bro) = SymbolTable.fresh (ft, Atom.atom "bro")
         val (ft,bru) = SymbolTable.fresh (ft, Atom.atom "bru")
         val (ft,ban) = SymbolTable.fresh (ft, Atom.atom "ban")
         val _ = SymbolTables.fieldTable := ft
         val t = TVar.freshTVar ()
         val s = TVar.freshTVar ()
         val u = TVar.freshTVar ()
         val v = TVar.freshTVar ()
         val w = TVar.freshTVar ()
         fun wBV tVar = VAR (tVar, BD.freshBVar ())
         fun getTVar (VAR (tv,bv)) = tv
           | getTVar _ = TVar.freshTVar ()
         val row1 = TVar.freshTVar ()
         fun rTy1 _ = Types.RECORD (row1,BD.freshBVar (),[
               Types.RField { name = foo, fty = Types.ZENO, exists = BD.freshBVar () },
               Types.RField { name = bar, fty = wBV s, exists = BD.freshBVar () },
               Types.RField { name = ban, fty = wBV t, exists = BD.freshBVar () }
            ])
         val row2 = TVar.freshTVar ()
         fun rTy2 _ = Types.RECORD (row2,BD.freshBVar (),[
               Types.RField { name = bro, fty = Types.ZENO, exists = BD.freshBVar () },
               Types.RField { name = bru, fty = wBV s, exists = BD.freshBVar () },
               Types.RField { name = bar, fty = wBV w, exists = BD.freshBVar () },
               Types.RField { name = baz, fty = wBV t, exists = BD.freshBVar () }
            ])
         val rIdx1 = newType (rTy1 (), table)
         val rIdx2 = newType (rTy2 (), table)
         val idxX = addSymbol (xVar,FUN ([ZENO,wBV t],VEC (wBV s)),table)
         val idxY = addSymbol (yVar,FUN ([wBV u,wBV t],wBV t),table)
         val idxZ = addSymbol (zVar,FUN ([rTy1 (), wBV t,wBV  v],rTy1 ()),table)
         val idx = newType (Types.VEC (Types.VAR (TVar.freshTVar (), BooleanDomain.freshBVar ())), table)

         val si = TVar.emptyShowInfo
         (*val (str,si) = toStringSI (fn _ => true, table, si);*)
         val _ = SymbolTables.varTable := SymbolTable.pop (!SymbolTables.varTable)
         (*val (tStr,si,varset) = showTableSI (table, ttGetVars (#typeTable table), si, TVar.empty);*)
         val (tStr,si) = dumpTableSI (table, si);
         val _ = TextIO.print ("type table:\n" ^ tStr)

         (*val (tVars,bVars) = delSymbol (zVar,table)
         val (tSetStr, si) = TVar.setToString (tVars,si)
         val bSetStr = BD.setToString bVars
         val _ = TextIO.print ("no more references to " ^ tSetStr ^ " and " ^ bSetStr ^ "\n")*)
         (*val _ = unify (rIdx1,rIdx2,table)*)
         (*val _ = instantiateSymbol (yVar, SymSet.singleton (xVar), yNewVar, table)*)
         val ty = getSymbol (zVar,table)
         val (tyStr,si) = showTypeSI (ty,si)
         val _ = TextIO.print ("z has the type " ^ tyStr ^ "\n")
         val _ = addSymbol (zVar,ty,table)
         (*val (tStr,si,varset) = showTableSI (table, ttGetVars (#typeTable table), si, TVar.empty);*)
         val (tStr,si) = dumpTableSI (table, si);
         val _ = TextIO.print ("again:\n" ^ tStr)
      in
         ()
      end
end
