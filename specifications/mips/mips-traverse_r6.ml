val revision/traverse f insn = 
   case insn of
      ADDIUPC x: f "ADDIUPC" (BINOP_LR x)
    | ALIGN x: f "ALIGN" (QUADOP_LRRR x)
    | ALUIPC x: f "ALUIPC" (BINOP_LR x)
    | AUI x: f "AUI" (TERNOP_LRR x)
    | AUIPC x: f "AUIPC" (BINOP_LR x)
    | BALC x: f "BALC" (UNOP_R x)
    | BC x: f "BC" (UNOP_R x)
    | BC1EQZ x: f "BC1EQZ" (BINOP_RR x)
    | BC1NEZ x: f "BC1NEZ" (BINOP_RR x)
    | BC2EQZ x: f "BC2EQZ" (BINOP_RR x)
    | BC2NEZ x: f "BC2NEZ" (BINOP_RR x)
    | BLEZALC x: f "BLEZALC" (BINOP_RR x)
    | BGEZALC x: f "BGEZALC" (BINOP_RR x)
    | BGTZALC x: f "BGTZALC" (BINOP_RR x)
    | BLTZALC x: f "BLTZALC" (BINOP_RR x)
    | BEQZALC x: f "BEQZALC" (BINOP_RR x)
    | BNEZALC x: f "BNEZALC" (BINOP_RR x)
    | BLEZC x: f "BLEZC" (BINOP_RR x)
    | BGEZC x: f "BGEZC" (BINOP_RR x)
    | BGEC x: f "BGEC" (TERNOP_RRR x)
    | BGTZC x: f "BGTZC" (BINOP_RR x)
    | BLTZC x: f "BLTZC" (BINOP_RR x)
    | BLTC x: f "BLTC" (TERNOP_RRR x)
    | BGEUC x: f "BGEUC" (TERNOP_RRR x)
    | BLTUC x: f "BLTUC" (TERNOP_RRR x)
    | BEQC x: f "BEQC" (TERNOP_RRR x)
    | BNEC x: f "BNEC" (TERNOP_RRR x)
    | BEQZC x: f "BEQZC" (BINOP_RR x)
    | BNEZC x: f "BNEZC" (BINOP_RR x)
    | BITSWAP x: f "BITSWAP" (BINOP_LR x)
    | BOVC x: f "BOVC" (TERNOP_RRR x)
    | BNVC x: f "BNVC" (TERNOP_RRR x)
    | CLASS-fmt x: f "CLASS" (BINOP_FLR x)
   end
