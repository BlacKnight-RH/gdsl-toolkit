#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <gdsl-x86.h>
#include <gdrr.h>
#include "rnati_NativeInterface.h"

//gcc -std=c99 -fPIC -shared -Wl,-soname,libjgdrr.so -I/usr/lib/jvm/java-6-openjdk-amd64/include -I/usr/lib/jvm/java-7-openjdk-amd64/include -I../.. -I../../include -o ../bin/libjgdrr.so rnati_NativeInterface.c ../../gdrr/Debug/libgdrr.a -L../../lib -lgdsl-x86 -lavcall
//echo "48 83 ec 08" | java -ss134217728 -Djava.library.path=. Program

struct closure {
	JNIEnv *env;
	jobject obj;
};

static jobject java_method_call(void *closure, char *name, int numargs, ...) {
	if(numargs > 3)
		return NULL; //Todo: Handle error

	struct closure *cls = (struct closure*)closure;

	jclass class = (*cls->env)->GetObjectClass(cls->env, cls->obj);

	char *signature;
	switch(numargs) {
		case 0: {
			signature = "()Ljava/lang/Object;";
			break;
		}
		case 1: {
			signature = "(Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
		case 2: {
			signature = "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
		case 3: {
			signature =
					"(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
			break;
		}
	}
	jmethodID mid = (*cls->env)->GetMethodID(cls->env, class, name, signature);

	jobject args[numargs];

	va_list list;
	va_start(list, numargs);
	for(int i = 0; i < numargs; ++i)
		args[i] = va_arg(list, jobject);
	va_end(list);

	jobject ret;
	switch(numargs) {
		case 0: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid);
			break;
		}
		case 1: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0]);
			break;
		}
		case 2: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0],
					args[1]);
			break;
		}
		case 3: {
			ret = (*cls->env)->CallObjectMethod(cls->env, cls->obj, mid, args[0],
					args[1], args[2]);
			break;
		}
	}

	return ret;
}

static jobject java_long_create(void *closure, long int x) {
	struct closure *cls = (struct closure*)closure;

	jclass class = (*cls->env)->FindClass(cls->env, "java/lang/Long");
	jmethodID method_id = (*cls->env)->GetMethodID(cls->env, class, "<init>",
			"(J)V");
	jobject a = (*cls->env)->NewObject(cls->env, class, method_id, x);

	return a;
}

// sem_id
static gdrr_sem_id_t *virt_na(void *closure, int_t con) {
	jobject ret;
	switch(con) {
		case CON_VIRT_EQ: {
			ret = java_method_call(closure, "virt_eq", 0);
			break;
		}
		case CON_VIRT_NEQ: {
			ret = java_method_call(closure, "virt_neq", 0);
			break;
		}
		case CON_VIRT_LES: {
			ret = java_method_call(closure, "virt_les", 0);
			break;
		}
		case CON_VIRT_LEU: {
			ret = java_method_call(closure, "virt_leu", 0);
			break;
		}
		case CON_VIRT_LTS: {
			ret = java_method_call(closure, "virt_lts", 0);
			break;
		}
		case CON_VIRT_LTU: {
			ret = java_method_call(closure, "virt_ltu", 0);
			break;
		}
	}
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *virt_t(void *closure, int_t t) {
	jobject ret = java_method_call(closure, "virt_t", 1,
			java_long_create(closure, (long int)t));
	return (gdrr_sem_id_t*)ret;
}
static gdrr_sem_id_t *x86(void *closure, int_t con) {
	jobject ret;
	switch(con) {
		case CON_Sem_IP: {
			ret = java_method_call(closure, "sem_ip", 0);
			break;
		}
		case CON_Sem_FLAGS: {
			ret = java_method_call(closure, "sem_flags", 0);
			break;
		}
		case CON_Sem_MXCSR: {
			ret = java_method_call(closure, "sem_mxcsr", 0);
			break;
		}
		case CON_Sem_AX: {
			ret = java_method_call(closure, "sem_ax", 0);
			break;
		}
		case CON_Sem_BX: {
			ret = java_method_call(closure, "sem_bx", 0);
			break;
		}
		case CON_Sem_CX: {
			ret = java_method_call(closure, "sem_cx", 0);
			break;
		}
		case CON_Sem_DX: {
			ret = java_method_call(closure, "sem_dx", 0);
			break;
		}
		case CON_Sem_SI: {
			ret = java_method_call(closure, "sem_si", 0);
			break;
		}
		case CON_Sem_DI: {
			ret = java_method_call(closure, "sem_di", 0);
			break;
		}
		case CON_Sem_SP: {
			ret = java_method_call(closure, "sem_sp", 0);
			break;
		}
		case CON_Sem_BP: {
			ret = java_method_call(closure, "sem_bp", 0);
			break;
		}
		case CON_Sem_R8: {
			ret = java_method_call(closure, "sem_r8", 0);
			break;
		}
		case CON_Sem_R9: {
			ret = java_method_call(closure, "sem_r9", 0);
			break;
		}
		case CON_Sem_R10: {
			ret = java_method_call(closure, "sem_r10", 0);
			break;
		}
		case CON_Sem_R11: {
			ret = java_method_call(closure, "sem_r11", 0);
			break;
		}
		case CON_Sem_R12: {
			ret = java_method_call(closure, "sem_r12", 0);
			break;
		}
		case CON_Sem_R13: {
			ret = java_method_call(closure, "sem_r13", 0);
			break;
		}
		case CON_Sem_R14: {
			ret = java_method_call(closure, "sem_r14", 0);
			break;
		}
		case CON_Sem_R15: {
			ret = java_method_call(closure, "sem_r15", 0);
			break;
		}
		case CON_Sem_CS: {
			ret = java_method_call(closure, "sem_cs", 0);
			break;
		}
		case CON_Sem_DS: {
			ret = java_method_call(closure, "sem_ds", 0);
			break;
		}
		case CON_Sem_SS: {
			ret = java_method_call(closure, "sem_ss", 0);
			break;
		}
		case CON_Sem_ES: {
			ret = java_method_call(closure, "sem_es", 0);
			break;
		}
		case CON_Sem_FS: {
			ret = java_method_call(closure, "sem_fs", 0);
			break;
		}
		case CON_Sem_GS: {
			ret = java_method_call(closure, "sem_gs", 0);
			break;
		}
		case CON_Sem_ST0: {
			ret = java_method_call(closure, "sem_st0", 0);
			break;
		}
		case CON_Sem_ST1: {
			ret = java_method_call(closure, "sem_st1", 0);
			break;
		}
		case CON_Sem_ST2: {
			ret = java_method_call(closure, "sem_st2", 0);
			break;
		}
		case CON_Sem_ST3: {
			ret = java_method_call(closure, "sem_st3", 0);
			break;
		}
		case CON_Sem_ST4: {
			ret = java_method_call(closure, "sem_st4", 0);
			break;
		}
		case CON_Sem_ST5: {
			ret = java_method_call(closure, "sem_st5", 0);
			break;
		}
		case CON_Sem_ST6: {
			ret = java_method_call(closure, "sem_st6", 0);
			break;
		}
		case CON_Sem_ST7: {
			ret = java_method_call(closure, "sem_st7", 0);
			break;
		}
		case CON_Sem_MM0: {
			ret = java_method_call(closure, "sem_mm0", 0);
			break;
		}
		case CON_Sem_MM1: {
			ret = java_method_call(closure, "sem_mm1", 0);
			break;
		}
		case CON_Sem_MM2: {
			ret = java_method_call(closure, "sem_mm2", 0);
			break;
		}
		case CON_Sem_MM3: {
			ret = java_method_call(closure, "sem_mm3", 0);
			break;
		}
		case CON_Sem_MM4: {
			ret = java_method_call(closure, "sem_mm4", 0);
			break;
		}
		case CON_Sem_MM5: {
			ret = java_method_call(closure, "sem_mm5", 0);
			break;
		}
		case CON_Sem_MM6: {
			ret = java_method_call(closure, "sem_mm6", 0);
			break;
		}
		case CON_Sem_MM7: {
			ret = java_method_call(closure, "sem_mm7", 0);
			break;
		}
		case CON_Sem_XMM0: {
			ret = java_method_call(closure, "sem_xmm0", 0);
			break;
		}
		case CON_Sem_XMM1: {
			ret = java_method_call(closure, "sem_xmm1", 0);
			break;
		}
		case CON_Sem_XMM2: {
			ret = java_method_call(closure, "sem_xmm2", 0);
			break;
		}
		case CON_Sem_XMM3: {
			ret = java_method_call(closure, "sem_xmm3", 0);
			break;
		}
		case CON_Sem_XMM4: {
			ret = java_method_call(closure, "sem_xmm4", 0);
			break;
		}
		case CON_Sem_XMM5: {
			ret = java_method_call(closure, "sem_xmm5", 0);
			break;
		}
		case CON_Sem_XMM6: {
			ret = java_method_call(closure, "sem_xmm6", 0);
			break;
		}
		case CON_Sem_XMM7: {
			ret = java_method_call(closure, "sem_xmm7", 0);
			break;
		}
		case CON_Sem_XMM8: {
			ret = java_method_call(closure, "sem_xmm8", 0);
			break;
		}
		case CON_Sem_XMM9: {
			ret = java_method_call(closure, "sem_xmm9", 0);
			break;
		}
		case CON_Sem_XMM10: {
			ret = java_method_call(closure, "sem_xmm10", 0);
			break;
		}
		case CON_Sem_XMM11: {
			ret = java_method_call(closure, "sem_xmm11", 0);
			break;
		}
		case CON_Sem_XMM12: {
			ret = java_method_call(closure, "sem_xmm12", 0);
			break;
		}
		case CON_Sem_XMM13: {
			ret = java_method_call(closure, "sem_xmm13", 0);
			break;
		}
		case CON_Sem_XMM14: {
			ret = java_method_call(closure, "sem_xmm14", 0);
			break;
		}
		case CON_Sem_XMM15: {
			ret = java_method_call(closure, "sem_xmm15", 0);
			break;
		}
	}
	return (gdrr_sem_id_t*)ret;
}

// sem_address
static gdrr_sem_address_t *sem_address(void *closure, int_t size,
		gdrr_sem_linear_t *address) {
	jobject ret = java_method_call(closure, "sem_address", 2,
			java_long_create(closure, (long int)size), (jobject)address);
	return (gdrr_sem_var_t*)ret;
}

// sem_var
static gdrr_sem_var_t *sem_var(void *closure, gdrr_sem_id_t *id, int_t offset) {
	jobject ret = java_method_call(closure, "sem_var", 2, (jobject)id,
			java_long_create(closure, (long int)offset));
	return (gdrr_sem_var_t*)ret;
}

// sem_linear
static gdrr_sem_linear_t *sem_lin_var(void *closure, gdrr_sem_var_t *this) {
	jobject ret = java_method_call(closure, "sem_lin_var", 1, (jobject)this);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_imm(void *closure, int_t imm) {
	jobject ret = java_method_call(closure, "sem_lin_imm", 1,
			java_long_create(closure, (long int)imm));
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_add(void *closure, gdrr_sem_linear_t *opnd1,
		gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_lin_add", 2, (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_sub(void *closure, gdrr_sem_linear_t *opnd1,
		gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_lin_sub", 2, (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_linear_t*)ret;
}
static gdrr_sem_linear_t *sem_lin_scale(void *closure, int_t imm,
		gdrr_sem_linear_t *opnd) {
	jobject ret = java_method_call(closure, "sem_lin_scale", 2,
			java_long_create(closure, (long int)imm), (jobject)opnd);
	return (gdrr_sem_linear_t*)ret;
}

// sem_sexpr
static gdrr_sem_sexpr_t *sem_sexpr_lin(void *closure, gdrr_sem_linear_t *this) {
	jobject ret = java_method_call(closure, "sem_sexpr_lin", 1, (jobject)this);
	return (gdrr_sem_sexpr_t*)ret;
}
static gdrr_sem_sexpr_t *sem_sexpr_cmp(void *closure, gdrr_sem_op_cmp_t *this) {
	jobject ret = java_method_call(closure, "sem_sexpr_cmp", 1, (jobject)this);
	return (gdrr_sem_sexpr_t*)ret;
}

// sem_op_cmp
static gdrr_sem_op_cmp_t *sem_cmpeq(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpeq", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}
static gdrr_sem_op_cmp_t *sem_cmpneq(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpneq", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}
static gdrr_sem_op_cmp_t *sem_cmples(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmples", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}
static gdrr_sem_op_cmp_t *sem_cmpleu(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpleu", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}
static gdrr_sem_op_cmp_t *sem_cmplts(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmplts", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}
static gdrr_sem_op_cmp_t *sem_cmpltu(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_cmpltu", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_cmp_t*)ret;
}

// sem_op
static gdrr_sem_op_t *sem_lin(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_lin", 2,
			java_long_create(closure, (long int)size), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_mul(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_mul", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_div(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_div", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_divs(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_divs", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_mod(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_mod", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shl(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shl", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shr(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shr", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_shrs(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_shrs", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_and(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_and", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_or(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_or", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_xor(void *closure, int_t size,
		gdrr_sem_linear_t *opnd1, gdrr_sem_linear_t *opnd2) {
	jobject ret = java_method_call(closure, "sem_xor", 3,
			java_long_create(closure, (long int)size), (jobject)opnd1,
			(jobject)opnd2);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_sx(void *closure, int_t size, int_t fromsize,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_sx", 3,
			java_long_create(closure, (long int)size),
			java_long_create(closure, (long int)fromsize), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_zx(void *closure, int_t size, int_t fromsize,
		gdrr_sem_linear_t *opnd1) {
	jobject ret = java_method_call(closure, "sem_zx", 3,
			java_long_create(closure, (long int)size),
			java_long_create(closure, (long int)fromsize), (jobject)opnd1);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_cmp(void *closure, gdrr_sem_op_cmp_t *this) {
	jobject ret = java_method_call(closure, "sem_cmp", 1, (jobject)this);
	return (gdrr_sem_op_t*)ret;
}
static gdrr_sem_op_t *sem_arb(void *closure, int_t size) {
	jobject ret = java_method_call(closure, "sem_arb", 1,
			java_long_create(closure, (long int)size));
	return (gdrr_sem_op_t*)ret;
}

// branch_hint
static gdrr_branch_hint_t *branch_hint(void *closure, int_t con) {
	char *func_n;
	switch(con) {
		case CON_HINT_JUMP: {
			func_n = "hint_jump";
			break;
		}
		case CON_HINT_CALL: {
			func_n = "hint_call";
			break;
		}
		case CON_HINT_RET: {
			func_n = "hint_ret";
			break;
		}
	}
	jobject ret = java_method_call(closure, func_n, 0);
	return (gdrr_branch_hint_t*)ret;
}

// sem_stmt
static gdrr_sem_stmt_t *sem_assign(void *closure, gdrr_sem_var_t *lhs,
		gdrr_sem_op_t *rhs) {
	jobject ret = java_method_call(closure, "sem_assign", 2, (jobject)lhs,
			(jobject)rhs);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_load(void *closure, gdrr_sem_var_t *lhs, int_t size,
		gdrr_sem_address_t *address) {
	jobject ret = java_method_call(closure, "sem_load", 3, (jobject)lhs,
			java_long_create(closure, (long)size), (jobject)address);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_store(void *closure, gdrr_sem_address_t *address,
		gdrr_sem_op_t *rhs) {
	jobject ret = java_method_call(closure, "sem_store", 2, (jobject)address,
			(jobject)rhs);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_ite(void *closure, gdrr_sem_sexpr_t *cond,
		gdrr_sem_stmts_t *then_branch, gdrr_sem_stmts_t *else_branch) {
	jobject ret = java_method_call(closure, "sem_ite", 3, (jobject)cond,
			(jobject)then_branch, (jobject)else_branch);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_while(void *closure, gdrr_sem_sexpr_t *cond,
		gdrr_sem_stmts_t *body) {
	jobject ret = java_method_call(closure, "sem_while", 2, (jobject)cond,
			(jobject)body);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_cbranch(void *closure, gdrr_sem_sexpr_t *cond,
		gdrr_sem_address_t *target_true, gdrr_sem_address_t *target_false) {
	jobject ret = java_method_call(closure, "sem_cbranch", 3, (jobject)cond,
			(jobject)target_true, (jobject)target_false);
	return (gdrr_sem_stmt_t*)ret;
}
static gdrr_sem_stmt_t *sem_branch(void *closure,
		gdrr_branch_hint_t *branch_hint, gdrr_sem_address_t *target) {
	jobject ret = java_method_call(closure, "sem_branch", 2, (jobject)branch_hint,
			(jobject)target);
	return (gdrr_sem_stmt_t*)ret;
}

// sem_stmts
static gdrr_sem_stmts_t *list_next(void *closure, gdrr_sem_stmt_t *next,
		gdrr_sem_stmts_t *list) {
	jobject ret = java_method_call(closure, "list_next", 2, (jobject)next,
			(jobject)list);
	return (gdrr_sem_stmts_t*)ret;
}
static gdrr_sem_stmts_t *list_init(void *closure) {
	jobject ret = java_method_call(closure, "list_init", 0);
	return (gdrr_sem_stmts_t*)ret;
}

JNIEXPORT
jobject
JNICALL Java_rnati_NativeInterface_decodeAndTranslateNative(JNIEnv *env,
		jobject obj, jbyteArray input) {
	if(input == NULL) {
		jclass exp = (*env)->FindClass(env, "java/lang/IllegalArgumentException");
		(*env)->ThrowNew(env, exp, "Input must not be null.");
		return NULL;
	}

	size_t length = (*env)->GetArrayLength(env, input);
	char *bytes = (char*)(*env)->GetByteArrayElements(env, input, 0);

	state_t state = gdsl_init();
	gdsl_set_code(state, bytes, length, 0);

	if(setjmp(*gdsl_err_tgt(state))) {
		jclass exp = (*env)->FindClass(env, "rnati/GdslDecodeException");
		(*env)->ThrowNew(env, exp, "Decode failed.");
		return NULL;
	}
	obj_t insn = x86_decode(state);

	if(setjmp(*gdsl_err_tgt(state))) {
		jclass exp = (*env)->FindClass(env, "rnati/RReilTranslateException");
		(*env)->ThrowNew(env, exp, "Translate failed.");
		return NULL;
	}
	obj_t rreil = x86_translate(state, insn);

//			__pretty(__rreil_pretty__, r, fmt, 2048);
//			printf("---------------------------\n");
//			puts(fmt);

	struct gdrr_config config;

	config.callbacks.sem_id.virt_na = &virt_na;
	config.callbacks.sem_id.virt_t = &virt_t;
	config.callbacks.arch.x86.sem_id.x86 = &x86;
	//%s/gdrr_sem_id_t .(.\(.*\))(void .closure);/config.callbacks.arch.x86.sem_id.\1 = \&\1;/g

	config.callbacks.sem_address.sem_address = &sem_address;

	config.callbacks.sem_var.sem_var = &sem_var;

	config.callbacks.sem_linear.sem_lin_var = &sem_lin_var;
	config.callbacks.sem_linear.sem_lin_imm = &sem_lin_imm;
	config.callbacks.sem_linear.sem_lin_add = &sem_lin_add;
	config.callbacks.sem_linear.sem_lin_sub = &sem_lin_sub;
	config.callbacks.sem_linear.sem_lin_scale = &sem_lin_scale;

	config.callbacks.sem_sexpr.sem_sexpr_lin = &sem_sexpr_lin;
	config.callbacks.sem_sexpr.sem_sexpr_cmp = &sem_sexpr_cmp;

	config.callbacks.sem_op_cmp.sem_cmpeq = &sem_cmpeq;
	config.callbacks.sem_op_cmp.sem_cmpneq = &sem_cmpneq;
	config.callbacks.sem_op_cmp.sem_cmples = &sem_cmples;
	config.callbacks.sem_op_cmp.sem_cmpleu = &sem_cmpleu;
	config.callbacks.sem_op_cmp.sem_cmplts = &sem_cmplts;
	config.callbacks.sem_op_cmp.sem_cmpltu = &sem_cmpltu;

	config.callbacks.sem_op.sem_lin = &sem_lin;
	config.callbacks.sem_op.sem_mul = &sem_mul;
	config.callbacks.sem_op.sem_div = &sem_div;
	config.callbacks.sem_op.sem_divs = &sem_divs;
	config.callbacks.sem_op.sem_mod = &sem_mod;
	config.callbacks.sem_op.sem_shl = &sem_shl;
	config.callbacks.sem_op.sem_shr = &sem_shr;
	config.callbacks.sem_op.sem_shrs = &sem_shrs;
	config.callbacks.sem_op.sem_and = &sem_and;
	config.callbacks.sem_op.sem_or = &sem_or;
	config.callbacks.sem_op.sem_xor = &sem_xor;
	config.callbacks.sem_op.sem_sx = &sem_sx;
	config.callbacks.sem_op.sem_zx = &sem_zx;
	config.callbacks.sem_op.sem_cmp = &sem_cmp;
	config.callbacks.sem_op.sem_arb = &sem_arb;

	config.callbacks.branch_hint.branch_hint = &branch_hint;

	config.callbacks.sem_stmt.sem_assign = &sem_assign;
	config.callbacks.sem_stmt.sem_load = &sem_load;
	config.callbacks.sem_stmt.sem_store = &sem_store;
	config.callbacks.sem_stmt.sem_ite = &sem_ite;
	config.callbacks.sem_stmt.sem_while = &sem_while;
	config.callbacks.sem_stmt.sem_cbranch = &sem_cbranch;
	config.callbacks.sem_stmt.sem_branch = &sem_branch;

	config.callbacks.sem_stmts_list.list_init = &list_init;
	config.callbacks.sem_stmts_list.list_next = &list_next;
	config.gdrr_config_stmts_handling = GDRR_CONFIG_STMTS_HANDLING_LIST;

	config.state = state;

	struct closure cls;
	cls.env = env;
	cls.obj = obj;
	config.closure = &cls;

	return gdrr_convert(rreil, &config);
}
