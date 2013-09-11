/*
 * dectran-cli-generic.c
 *
 *  Created on: Sep 11, 2013
 *      Author: jucs
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <readhex.h>
#include <gdsl_multiplex.h>

int main(int argc, char** argv) {
	uint8_t *buffer;
	size_t size = readhex_hex_read(stdin, &buffer);

	char **backends;
	size_t backends_count = gdsl_multiplex_backends_list(&backends);

	for (size_t i = 0; i < backends_count; ++i) {
		printf("%s\n", backends[i]);
	}

//	state_t state = gdsl_init();
//	gdsl_set_code(state, (char*)buffer, size, 0);
//
//	if(setjmp(*gdsl_err_tgt(state))) {
//		fprintf(stderr, "decode failed: %s\n", gdsl_get_error_message(state));
//		exit(1);
//	}
//	obj_t insn = gdsl_decode(state);
//
//	printf("[");
//	size_t decoded = gdsl_get_ip_offset(state);
//	for (size_t i = 0; i < decoded; ++i) {
//		if(i)
//			printf(" ");
//		printf("%02x", buffer[i]);
//	}
//	printf("] ");
//
//	string_t fmt = gdsl_merge_rope(state, gdsl_pretty(state, insn));
//	puts(fmt);
//
//	printf("---------------------------\n");
//
//	if(setjmp(*gdsl_err_tgt(state))) {
//		fprintf(stderr, "translate failed: %s\n", gdsl_get_error_message(state));
//		exit(1);
//	}
//
//	obj_t rreil = gdsl_translate(state, insn);
//
//	fmt = gdsl_merge_rope(state, gdsl_rreil_pretty(state, rreil));
//	puts(fmt);
//
//	gdsl_destroy(state);
//	free(buffer);

	return 1;
}

