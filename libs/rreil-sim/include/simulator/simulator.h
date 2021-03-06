/*
 * simulator.h
 *
 *  Created on: 07.05.2013
 *      Author: jucs
 */

#ifndef SIMULATOR_H_
#define SIMULATOR_H_

#include <stdint.h>
#include <rreil/rreil.h>
#include <context.h>

enum simulator_error {
	SIMULATOR_ERROR_NONE = 0,
	SIMULATOR_ERROR_UNALIGNED_STORE = 1,
	SIMULATOR_ERROR_UNDEFINED_ADDRESS = 2,
	SIMULATOR_ERROR_UNDEFINED_STORE = 4,
	SIMULATOR_ERROR_UNDEFINED_BRANCH = 8,
	SIMULATOR_ERROR_FLOP_UNIMPLEMENTED = 16,
	SIMULATOR_ERROR_PRIMITIVE_UNKNOWN = 32,
	SIMULATOR_ERROR_PRIMITIVE_SIGNATURE_INVALID = 64,
	SIMULATOR_ERROR_MAX_LOOP_ITERATIONS_COUNT_EXCEEDED = 128,
	SIMULATOR_ERROR_EXCEPTION = 256
};

#define SIMULATOR_ERRORS_COUNT 10

extern enum simulator_error simulator_statements_simulate(struct context *context,
		struct rreil_statements *statements);

#endif /* SIMULATOR_H_ */
