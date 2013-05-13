/*
 * rreil_print.c
 *
 *  Created on: 06.05.2013
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <rreil/rreil.h>

void rreil_address_print(struct rreil_address *address) {
	printf("{%lu} ", address->size);
	rreil_linear_print(address->address);
}

void rreil_branch_hint_print(enum rreil_branch_hint *hint) {
	switch(*hint) {
		case RREIL_BRANCH_HINT_JUMP: {
			printf("JUMP");
			break;
		}
		case RREIL_BRANCH_HINT_CALL: {
			printf("CALL");
			break;
		}
		case RREIL_BRANCH_HINT_RET: {
			printf("RET");
			break;
		}
	}
}

void rreil_comparator_print(struct rreil_comparator *comparator) {
	printf("{%lu->1} ", comparator->arity2.size);
	rreil_linear_print(comparator->arity2.opnd1);
	switch(comparator->type) {
		case RREIL_COMPARATOR_TYPE_EQ: {
			printf(" == ");
			break;
		}
		case RREIL_COMPARATOR_TYPE_NEQ: {
			printf(" != ");
			break;
		}
		case RREIL_COMPARATOR_TYPE_LES: {
			printf(" <=s ");
			break;
		}
		case RREIL_COMPARATOR_TYPE_LEU: {
			printf(" <=u ");
			break;
		}
		case RREIL_COMPARATOR_TYPE_LTS: {
			printf(" <s ");
			break;
		}
		case RREIL_COMPARATOR_TYPE_LTU: {
			printf(" <u ");
			break;
		}
	}
	rreil_linear_print(comparator->arity2.opnd2);
}

void rreil_id_x86_print(enum rreil_id_x86 x86) {
	switch(x86) {
		case RREIL_ID_X86_IP: {
			printf("IP");
			break;
		}
		case RREIL_ID_X86_FLAGS: {
			printf("FLAGS");
			break;
		}
		case RREIL_ID_X86_MXCSR: {
			printf("MXCSR");
			break;
		}
		case RREIL_ID_X86_AX: {
			printf("AX");
			break;
		}
		case RREIL_ID_X86_BX: {
			printf("BX");
			break;
		}
		case RREIL_ID_X86_CX: {
			printf("CX");
			break;
		}
		case RREIL_ID_X86_DX: {
			printf("DX");
			break;
		}
		case RREIL_ID_X86_SI: {
			printf("SI");
			break;
		}
		case RREIL_ID_X86_DI: {
			printf("DI");
			break;
		}
		case RREIL_ID_X86_SP: {
			printf("SP");
			break;
		}
		case RREIL_ID_X86_BP: {
			printf("BP");
			break;
		}
		case RREIL_ID_X86_R8: {
			printf("R8");
			break;
		}
		case RREIL_ID_X86_R9: {
			printf("R9");
			break;
		}
		case RREIL_ID_X86_R10: {
			printf("R10");
			break;
		}
		case RREIL_ID_X86_R11: {
			printf("R11");
			break;
		}
		case RREIL_ID_X86_R12: {
			printf("R12");
			break;
		}
		case RREIL_ID_X86_R13: {
			printf("R13");
			break;
		}
		case RREIL_ID_X86_R14: {
			printf("R14");
			break;
		}
		case RREIL_ID_X86_R15: {
			printf("R15");
			break;
		}
		case RREIL_ID_X86_CS: {
			printf("CS");
			break;
		}
		case RREIL_ID_X86_DS: {
			printf("DS");
			break;
		}
		case RREIL_ID_X86_SS: {
			printf("SS");
			break;
		}
		case RREIL_ID_X86_ES: {
			printf("ES");
			break;
		}
		case RREIL_ID_X86_FS: {
			printf("FS");
			break;
		}
		case RREIL_ID_X86_GS: {
			printf("GS");
			break;
		}
		case RREIL_ID_X86_ST0: {
			printf("ST0");
			break;
		}
		case RREIL_ID_X86_ST1: {
			printf("ST1");
			break;
		}
		case RREIL_ID_X86_ST2: {
			printf("ST2");
			break;
		}
		case RREIL_ID_X86_ST3: {
			printf("ST3");
			break;
		}
		case RREIL_ID_X86_ST4: {
			printf("ST4");
			break;
		}
		case RREIL_ID_X86_ST5: {
			printf("ST5");
			break;
		}
		case RREIL_ID_X86_ST6: {
			printf("ST6");
			break;
		}
		case RREIL_ID_X86_ST7: {
			printf("ST7");
			break;
		}
		case RREIL_ID_X86_MM0: {
			printf("MM0");
			break;
		}
		case RREIL_ID_X86_MM1: {
			printf("MM1");
			break;
		}
		case RREIL_ID_X86_MM2: {
			printf("MM2");
			break;
		}
		case RREIL_ID_X86_MM3: {
			printf("MM3");
			break;
		}
		case RREIL_ID_X86_MM4: {
			printf("MM4");
			break;
		}
		case RREIL_ID_X86_MM5: {
			printf("MM5");
			break;
		}
		case RREIL_ID_X86_MM6: {
			printf("MM6");
			break;
		}
		case RREIL_ID_X86_MM7: {
			printf("MM7");
			break;
		}
		case RREIL_ID_X86_XMM0: {
			printf("XMM0");
			break;
		}
		case RREIL_ID_X86_XMM1: {
			printf("XMM1");
			break;
		}
		case RREIL_ID_X86_XMM2: {
			printf("XMM2");
			break;
		}
		case RREIL_ID_X86_XMM3: {
			printf("XMM3");
			break;
		}
		case RREIL_ID_X86_XMM4: {
			printf("XMM4");
			break;
		}
		case RREIL_ID_X86_XMM5: {
			printf("XMM5");
			break;
		}
		case RREIL_ID_X86_XMM6: {
			printf("XMM6");
			break;
		}
		case RREIL_ID_X86_XMM7: {
			printf("XMM7");
			break;
		}
		case RREIL_ID_X86_XMM8: {
			printf("XMM8");
			break;
		}
		case RREIL_ID_X86_XMM9: {
			printf("XMM9");
			break;
		}
		case RREIL_ID_X86_XMM10: {
			printf("XMM10");
			break;
		}
		case RREIL_ID_X86_XMM11: {
			printf("XMM11");
			break;
		}
		case RREIL_ID_X86_XMM12: {
			printf("XMM12");
			break;
		}
		case RREIL_ID_X86_XMM13: {
			printf("XMM13");
			break;
		}
		case RREIL_ID_X86_XMM14: {
			printf("XMM14");
			break;
		}
		case RREIL_ID_X86_XMM15: {
			printf("XMM15");
			break;
		}
	}
}

void rreil_id_print(struct rreil_id *id) {
	switch(id->type) {
		case RREIL_ID_TYPE_VIRTUAL: {
			switch(id->virtual) {
				case RREIL_ID_VIRTUAL_EQ: {
					printf("RREIL_ID_VIRTUAL_EQ");
					break;
				}
				case RREIL_ID_VIRTUAL_NEQ: {
					printf("RREIL_ID_VIRTUAL_NEQ");
					break;
				}
				case RREIL_ID_VIRTUAL_LES: {
					printf("RREIL_ID_VIRTUAL_LES");
					break;
				}
				case RREIL_ID_VIRTUAL_LEU: {
					printf("RREIL_ID_VIRTUAL_LEU");
					break;
				}
				case RREIL_ID_VIRTUAL_LTS: {
					printf("RREIL_ID_VIRTUAL_LTS");
					break;
				}
				case RREIL_ID_VIRTUAL_LTU: {
					printf("RREIL_ID_VIRTUAL_LTU");
					break;
				}
			}
			break;
		}
		case RREIL_ID_TYPE_TEMPORARY: {
			printf("T%lu", id->temporary);
			break;
		}
		case RREIL_ID_TYPE_X86: {
			rreil_id_x86_print(id->x86);
			break;
		}
	}
}

void rreil_linear_print(struct rreil_linear *linear) {
	switch(linear->type) {
		case RREIL_LINEAR_TYPE_VARIABLE: {
			rreil_variable_print(linear->variable);
			break;
		}
		case RREIL_LINEAR_TYPE_IMMEDIATE: {
			printf("%lu", linear->immediate);
			break;
		}
		case RREIL_LINEAR_TYPE_SUM: {
			printf("(");
			rreil_linear_print(linear->sum.opnd1);
			printf(" + ");
			rreil_linear_print(linear->sum.opnd2);
			printf(")");
			break;
		}
		case RREIL_LINEAR_TYPE_DIFFERENCE: {
			printf("(");
			rreil_linear_print(linear->difference.opnd1);
			printf(" - ");
			rreil_linear_print(linear->difference.opnd2);
			printf(")");
			break;
		}
		case RREIL_LINEAR_TYPE_SCALE: {
			printf("%lu*", linear->scale.imm);
			rreil_linear_print(linear->scale.opnd);
			break;
		}
	}
}

void rreil_op_print(struct rreil_op *op) {
	switch(op->type) {
		case RREIL_OP_TYPE_LIN: {
			printf("{%lu} ", op->lin.size);
			rreil_linear_print(op->lin.opnd1);
			break;
		}
		case RREIL_OP_TYPE_MUL: {
			printf("{%lu} ", op->mul.size);
			rreil_linear_print(op->mul.opnd1);
			printf(" * ");
			rreil_linear_print(op->mul.opnd2);
			break;
		}
		case RREIL_OP_TYPE_DIV: {
			printf("{%lu} ", op->div.size);
			rreil_linear_print(op->div.opnd1);
			printf(" /u ");
			rreil_linear_print(op->div.opnd2);
			break;
		}
		case RREIL_OP_TYPE_DIVS: {
			printf("{%lu} ", op->divs.size);
			rreil_linear_print(op->divs.opnd1);
			printf(" /s ");
			rreil_linear_print(op->divs.opnd2);
			break;
		}
		case RREIL_OP_TYPE_MOD: {
			printf("{%lu} ", op->mod.size);
			rreil_linear_print(op->mod.opnd1);
			printf(" %% ");
			rreil_linear_print(op->mod.opnd2);
			break;
		}
		case RREIL_OP_TYPE_SHL: {
			printf("{%lu} ", op->shl.size);
			rreil_linear_print(op->shl.opnd1);
			printf(" << ");
			rreil_linear_print(op->shl.opnd2);
			break;
		}
		case RREIL_OP_TYPE_SHR: {
			printf("{%lu} ", op->shr.size);
			rreil_linear_print(op->shr.opnd1);
			printf(" >>u ");
			rreil_linear_print(op->shr.opnd2);
			break;
		}
		case RREIL_OP_TYPE_SHRS: {
			printf("{%lu} ", op->shrs.size);
			rreil_linear_print(op->shrs.opnd1);
			printf(" >>s ");
			rreil_linear_print(op->shrs.opnd2);
			break;
		}
		case RREIL_OP_TYPE_AND: {
			printf("{%lu} ", op->and.size);
			rreil_linear_print(op->and.opnd1);
			printf(" & ");
			rreil_linear_print(op->and.opnd2);
			break;
		}
		case RREIL_OP_TYPE_OR: {
			printf("{%lu} ", op->or.size);
			rreil_linear_print(op->or.opnd1);
			printf(" | ");
			rreil_linear_print(op->or.opnd2);
			break;
		}
		case RREIL_OP_TYPE_XOR: {
			printf("{%lu} ", op->xor.size);
			rreil_linear_print(op->xor.opnd1);
			printf(" ^ ");
			rreil_linear_print(op->xor.opnd2);
			break;
		}
		case RREIL_OP_TYPE_SX: {
			printf("{%lu->s%lu} ", op->sx.fromsize, op->sx.size);
			rreil_linear_print(op->sx.opnd);
			break;
		}
		case RREIL_OP_TYPE_ZX: {
			printf("{%lu->u%lu} ", op->zx.fromsize, op->zx.size);
			rreil_linear_print(op->zx.opnd);
			break;
		}
		case RREIL_OP_TYPE_CMP: {
			rreil_comparator_print(op->cmp);
			break;
		}
		case RREIL_OP_TYPE_ARB: {
			printf("{%lu} arbitrary", op->arb.size);
			break;
		}
	}
}

void rreil_sexpr_print(struct rreil_sexpr *sexpr) {
	switch(sexpr->type) {
		case RREIL_SEXPR_TYPE_LIN: {
			rreil_linear_print(sexpr->lin);
			break;
		}
		case RREIL_SEXPR_TYPE_CMP: {
			rreil_comparator_print(sexpr->cmp);
			break;
		}
	}
}

void rreil_variable_print(struct rreil_variable *variable) {
	rreil_id_print(variable->id);
	if(variable->offset)
		printf("/%lu", variable->offset);
}

void rreil_statement_print(struct rreil_statement *statement) {
	switch(statement->type) {
		case RREIL_STATEMENT_TYPE_ASSIGN: {
			rreil_variable_print(statement->assign.lhs);
			printf(" = ");
			rreil_op_print(statement->assign.rhs);
			break;
		}
		case RREIL_STATEMENT_TYPE_LOAD: {
			rreil_variable_print(statement->load.lhs);
			printf(" = {%lu} *(", statement->load.size);
			rreil_address_print(statement->load.address);
			printf(")");
			break;
		}
		case RREIL_STATEMENT_TYPE_STORE: {
			printf("*(");
			rreil_address_print(statement->store.address);
			printf(") = ");
			rreil_op_print(statement->store.rhs);
			break;
		}
		case RREIL_STATEMENT_TYPE_ITE: {
			printf("if(");
			rreil_sexpr_print(statement->ite.cond);
			printf(") {\n");
			rreil_statements_print(statement->ite.then_branch);
			printf("} else {\n");
			rreil_statements_print(statement->ite.else_branch);
			printf("}");
			break;
		}
		case RREIL_STATEMENT_TYPE_WHILE: {
			printf("while(");
			rreil_sexpr_print(statement->while_.cond);
			printf(") {\n");
			rreil_statements_print(statement->while_.body);
			printf("}");
			break;
		}
		case RREIL_STATEMENT_TYPE_CBRANCH: {
			printf("if(");
			rreil_sexpr_print(statement->cbranch.cond);
			printf(") { goto ");
			rreil_address_print(statement->cbranch.target_true);
			printf(" } else { goto");
			rreil_address_print(statement->cbranch.target_false);
			printf("}");
			break;
		}
		case RREIL_STATEMENT_TYPE_BRANCH: {
			printf("goto [");
			rreil_branch_hint_print(statement->branch.hint);
			printf("] ");
			rreil_address_print(statement->branch.target);
			break;
		}
	}
}

void rreil_statements_print(struct rreil_statements *statements) {
	for(size_t i = 0; i < statements->statements_length; ++i) {
		rreil_statement_print(statements->statements[i]);
		printf("\n");
	}
}
