/*
 * tester.h
 *
 *  Created on: 14.05.2013
 *      Author: jucs
 */

#ifndef TBGEN_H_
#define TBGEN_H_

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <context.h>
#include <simulator/tracking.h>
#include <x86.h>

enum tbgen_result_type {
	TBGEN_RTYPE_SUCCESS, TBGEN_RTYPE_ERROR
};

struct tbgen_result {
	enum tbgen_result_type result;

	uint8_t *buffer;
	size_t buffer_length;

	size_t instruction_offset;

	uint8_t *jump_marker;
	size_t jump_marker_length;
};

extern void tbgen_push_generate(FILE *stream, enum x86_id register_);
extern void tbgen_pop_generate(FILE *stream, enum x86_id register_);
extern void tbgen_push_rflags_generate(FILE *stream);
extern void tbgen_pop_rflags_generate(FILE *stream);
extern void tbgen_mov_standard_old_register_generate(FILE *stream,
		enum x86_id from, enum x86_id to);
extern void tbgen_xchg_rsp_generate(FILE *stream, enum x86_id other);

extern struct tbgen_result tbgen_code_generate(uint8_t *instruction,
		size_t instruction_length, struct tracking_trace *trace,
		struct context *context, char test_unused);

#endif /* TBGEN_H_ */
