export generalize : (insndata) -> asm-insn

val generalize insn = let
  val recordify mnemonic ua = {mnemonic=mnemonic, ua=ua}
  val traversed = traverse recordify insn.insn
in
  asm-insn-flags insn.length (string-from-rope traversed.mnemonic) (generalize-fmt traversed.ua) (generalize-ua traversed.ua)
end

val generalize-lvalue lval = let
  val generalize-register r = asm-reg (string-from-rope (show/register r))
in case lval of
   GPR r: generalize-register r
 | FPR f: generalize-register f
end end

val generalize-rvalue rval =
   case rval of
      LVALUE lval: generalize-lvalue lval
    | IMM i: generalize-immediate i
    | FCC fc: generalize-fcc fc
   end

val generalize-format fmt = asm-ann-string (string-from-rope (show/format fmt))
val generalize-condop cond = asm-ann-string (string-from-rope (show/condop cond))

val generalize-fcc fcc = asm-reg (string-from-rope (show/fccode fcc))

val generalize-immediate i = let
   val inner i sz = asm-bounded (asm-boundary-sz sz) (asm-imm (zx i))
in case i of
   IMM5 i: inner i 5
 | IMM16 i: inner i 16
 | OFFSET9 i: inner i 9
 | OFFSET16 i: inner i 16
 | SEL i: inner i 3
 | IMPL i: inner i 16
 | CODE10 i: inner i 10
 | CODE19 i: inner i 19
 | CODE20 i: inner i 20
 | STYPE i: inner i 5
 | POSSIZE i: inner i 5
 | SIZE i: inner i 5
 | POS i: inner i 5
 | HINT i: inner i 5
 | INSTRINDEX i: inner i 26
 | COFUN i: inner i 25
 | OP i: inner i 5
end end

# -> sftl
val generalize-ua ua =
   case ua of
      NULLOP: asm-opnds-none
    | UNOP_R x: asm-opnds-one (generalize-rvalue x.op)
    | UNOP_L x: asm-opnds-one (generalize-lvalue x.op)
    | BINOP_RR x: asm-opnds-more (generalize-rvalue x.op1) (asm-opnds-one (generalize-rvalue x.op2))
    | BINOP_LR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-one (generalize-rvalue x.op2))
    | BINOP_FLR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-one (generalize-rvalue x.op2))
    | TERNOP_RRR x: asm-opnds-more (generalize-rvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-one (generalize-rvalue x.op3)))
    | TERNOP_LRR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-one (generalize-rvalue x.op3)))
    | TERNOP_FLRR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-one (generalize-rvalue x.op3)))
    | TERNOP_CFLRR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-one (generalize-rvalue x.op3)))
    | QUADOP_LRRR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-more (generalize-rvalue x.op3) (asm-opnds-one (generalize-rvalue x.op4))))
    | QUADOP_FLRRR x: asm-opnds-more (generalize-lvalue x.op1) (asm-opnds-more (generalize-rvalue x.op2) (asm-opnds-more (generalize-rvalue x.op3) (asm-opnds-one (generalize-rvalue x.op4))))
   end


val generalize-fmt ua =
   case ua of
      NULLOP: asm-anns-none
    | UNOP_R x: asm-anns-none
    | UNOP_L x: asm-anns-none
    | BINOP_RR x: asm-anns-none
    | BINOP_LR x: asm-anns-none
    | BINOP_FLR x: asm-anns-one (generalize-format x.fmt)
    | TERNOP_RRR x: asm-anns-none
    | TERNOP_LRR x: asm-anns-none
    | TERNOP_FLRR x: asm-anns-one (generalize-format x.fmt)
    | TERNOP_CFLRR x: asm-anns-more (generalize-format x.fmt) (asm-anns-one (generalize-condop x.cond))
    | QUADOP_LRRR x: asm-anns-none
    | QUADOP_FLRRR x: asm-anns-one (generalize-format x.fmt)
   end


# <- sutl
