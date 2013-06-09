/* vim:cindent:ts=2:sw=2:expandtab */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>
#include <dis.h>
#include <sys/resource.h>

#include <err.h>
#include <fcntl.h>
#include <gelf.h>
#include <string.h>
#include <sysexits.h>

#include <time.h>

char elf_section_boundary_get(char *path, size_t *offset, size_t *size) {
	char retval = 0;

	int fd = open(path, O_RDONLY);
	if(!fd) {
		retval = 8;
		goto end_0;
	}

	if(elf_version(EV_CURRENT) == EV_NONE) {
		retval = 2;
		goto end_0;
	}

	Elf *e = elf_begin(fd, ELF_C_READ, NULL);
	if(!e) {
		retval = 3;
		goto end_0;
	}

	if(elf_kind(e) != ELF_K_ELF) {
		retval = 4;
		goto end_1;
	}

	size_t shstrndx;
	if(elf_getshdrstrndx(e, &shstrndx) != 0) {
		retval = 5;
		goto end_1;
	}

	Elf_Scn *scn = NULL;

	char found = 0;
	while((scn = elf_nextscn(e, scn)) != NULL) {
		GElf_Shdr shdr;
		if(gelf_getshdr(scn, &shdr) != &shdr) {
			retval = 6;
			goto end_1;
		}

		char *name = elf_strptr(e, shstrndx, shdr.sh_name);
		if(!name) {
			retval = 7;
			goto end_1;
		}
		if(!strcmp(name, ".text")) {
			*offset = shdr.sh_offset;
			*size = shdr.sh_size;
			found = 1;
			break;
		}
//		printf("%s - %zu:%zu\n", name, shdr.sh_offset, shdr.sh_size);
	}

	if(!found)
		retval = 1;

	end_1: elf_end(e);

	end_0: close(fd);

	return retval;
}

enum p_option {
	OPTION_ELF, OPTION_OFFSET, OPTION_CHILDREN, OPTION_FILE, OPTION_CLEANUP
};

struct options {
	char elf;
	size_t offset;
	char children_consider;
	char *file;
	char cleanup;
};

static char args_parse(int argc, char **argv, struct options *options) {
	options->elf = 0;
	options->offset = 0;
	options->children_consider = 0;
	options->file = NULL;
	options->cleanup = 0;

	struct option long_options[] = { { "elf", no_argument, NULL, OPTION_ELF }, {
			"offset", required_argument, NULL, OPTION_OFFSET }, { "children",
			no_argument, NULL, OPTION_CHILDREN }, { "file", required_argument, NULL,
			OPTION_FILE }, { "cleanup", no_argument, NULL, OPTION_CLEANUP }, { 0, 0,
			0, 0 }, };

	while(1) {
		int result = getopt_long(argc, argv, "", long_options, NULL);
		if(result < 0)
			break;
		switch(result) {
			case OPTION_ELF: {
				options->elf = 1;
				break;
			}
			case OPTION_OFFSET: {
				sscanf(optarg, "%lu", &options->offset);
				break;
			}
			case OPTION_CHILDREN: {
				options->children_consider = 1;
				break;
			}
			case OPTION_FILE: {
				options->file = optarg;
				break;
			}
			case OPTION_CLEANUP: {
				options->cleanup = 1;
				break;
			}
			case '?':
				return 2;
		}
	}

	if(!options->file)
		return 1;

	return 0;
}

__obj translate(__obj *state) {
	__obj rreil_insns = __runMonadicNoArg(__translateBlock__, state);

	return rreil_insns;
}

__obj translate_super(__obj *state, __obj *rreil_insns) {
	__obj rreil_insns_succs = __runMonadicNoArg(__translateSuperBlock__, state);

	*rreil_insns = __RECORD_SELECT(rreil_insns_succs, ___insns);

	return rreil_insns_succs;
}

void print_succs(__obj translated, char *fmt, size_t size) {
	__obj succ_a = __RECORD_SELECT(translated, ___succ_a);
	__obj succ_b = __RECORD_SELECT(translated, ___succ_b);

	void print_succ(__obj succ, char const *name) {
		switch(__CASETAGCON(succ)) {
			case __SO_SOME: {
				__obj succ_insns = __DECON(succ);
				printf("Succ %s:\n", name);
				__pretty(__rreil_pretty__, succ_insns, fmt, size);
				puts(fmt);
				break;
			}
			case __SO_NONE: {
				printf("Succ %s: __SO_NONE :-(\n", name);
				break;
			}
		}
	}

	print_succ(succ_a, "a");
	print_succ(succ_b, "b");
}

int main(int argc, char** argv) {
	struct options options;
	if(args_parse(argc, argv, &options)) {
		printf(
				"Usage: liveness-sweep [--children] [--offset offset] [--elf] [--cleanup] --file file\n");
		return 42;
	}

	printf("elf=%d, offset=%lu, children=%d, file=%s, cleanup=%d\n", options.elf,
			options.offset, options.children_consider, options.file, options.cleanup);

	const rlim_t kStackSize = 4096L * 1024L * 1024L;
	struct rlimit rl;
	int result;

	result = getrlimit(RLIMIT_STACK, &rl);
	if(result == 0) {
		if(rl.rlim_cur < kStackSize) {
			rl.rlim_cur = kStackSize;
			result = setrlimit(RLIMIT_STACK, &rl);
			if(result != 0) {
				fprintf(stderr, "setrlimit returned result = %d\n", result);
			}
		}
	}

	size_t size = 16 * 1024 * 1024;
	char *fmt = (char*)malloc(size);

	size_t offset;
	size_t size_max;

	if(options.elf) {
		char e = elf_section_boundary_get(options.file, &offset, &size_max);
		if(e)
			return 2;
	} else {
		offset = 0;
		size_max = 0;
	}

//	if(argc == 3) {
//		if(strcmp(argv[1], "--elf"))
//			return 1;
//		char e = elf_section_boundary_get(argv[2], &offset, &size_max);
//		if(e)
//			return 2;
//	} else if(argc != 2) {
//		printf("Usage: liveness-sweep [--elf] file\n");
//		return 1;
//	} else {
//		offset = 0;
//		size_max = 0;
//	}

//	FILE *f = fopen(argv[1 + (argc == 3)], "r");
	FILE *f = fopen(options.file, "r");
	if(!f) {
		printf("Unable to open file.\n");
		return 1;
	}

	fseek(f, offset, SEEK_SET);

	size_t buffer_size = 128;
	unsigned char *buffer = NULL;
	size_t buffer_length = 0;
	do {
		buffer_size *= 2;
		buffer = (unsigned char*)realloc(buffer, buffer_size);
		buffer_length += fread(buffer + buffer_length, 1,
				buffer_size - buffer_length, f);
	} while(!feof(f) && (!size_max || buffer_length < size_max));

	fclose(f);

	//printf("size_max: %lu, buffer_length: %lu\n", size_max, buffer_length);

	if(size_max && buffer_length > size_max)
		buffer_length = size_max;

	if(buffer_length == buffer_size) {
		buffer_size++;
		buffer = (unsigned char*)realloc(buffer, buffer_size);
	}
	buffer[buffer_length++] = 0xc3; //Last instruction should be a jump (ret) ;-).

	size_t lines = 0;
	size_t lines_greedy = 0;

	long time_non_opt = 0;
	long time_opt = 0;

	struct timespec start;
	struct timespec end;

	size_t native_instructions = 0;

	printf("buffer_length=%zu\n", buffer_length);

	uint64_t consumed = options.offset;
//	uint64_t consumed = 228;
//	uint64_t consumed = 0;

	while(consumed < buffer_length) {
		printf("### Next block (@offset %lu): ###\n\n", consumed);

		__obj state = __createState(buffer + consumed, buffer_length - consumed,
				consumed, 0);

		__obj translated;
		__obj rreil_insns;
		clock_gettime(CLOCK_MONOTONIC_RAW, &start);
		if(options.children_consider)
			translated = translate_super(&state, &rreil_insns);
		else
			translated = rreil_insns = translate(&state);
		clock_gettime(CLOCK_MONOTONIC_RAW, &end);
		long diff = end.tv_nsec - start.tv_nsec;
		time_non_opt += diff > 0 ? diff : 0;

		if(!__isNil(rreil_insns)) {
			__fatal("TranslateBlock failed");
			goto end;
		}

		if(options.children_consider)
			print_succs(translated, fmt, size);

		__obj native_instruction_count = __RECORD_SELECT(state, ___ins_count);
		native_instructions += __CASETAGINT(native_instruction_count);

		//printf("%x\n", buffer[consumed]);

		printf("Initial RREIL instructions:\n");
		__pretty(__rreil_pretty__, rreil_insns, fmt, size);
		puts(fmt);
		printf("\n");

		for(size_t i = 0; fmt[i]; i++)
			if(fmt[i] == '\n')
				lines++;

		__obj lv_result;
		clock_gettime(CLOCK_MONOTONIC_RAW, &start);
		if(options.children_consider)
			lv_result = __runMonadicOneArg(__liveness_super__, &state, translated);
		else
			lv_result = __runMonadicOneArg(__liveness__, &state, translated);
		clock_gettime(CLOCK_MONOTONIC_RAW, &end);
		diff = end.tv_nsec - start.tv_nsec;
		time_opt += diff > 0 ? diff : 0;
//		if(!__isNil(greedy_state)) {
//			__fatal("Liveness failed");
//			goto end;
//		}

		__obj rreil_instructions_greedy = __RECORD_SELECT(state, ___live);
		if(!__isNil(rreil_instructions_greedy)) {
			__fatal("Liveness failed (no greedy instructions)");
			goto end;
		}

		if(options.children_consider) {
			__obj initial_state = __RECORD_SELECT(lv_result, ___initial);
			printf("Liveness initial state:\n");
			__pretty(__lv_pretty__, initial_state, fmt, size);
			puts(fmt);
			printf("\n");
		}

		__obj greedy_state;
		if(options.children_consider)
			greedy_state = __RECORD_SELECT(lv_result, ___after);
		else
			greedy_state = lv_result;
		printf("Liveness greedy state:\n");
		__pretty(__lv_pretty__, greedy_state, fmt, size);
		puts(fmt);
		printf("\n");

		if(options.cleanup) {
			printf("RREIL instructions after LV (greedy), before cleanup:\n");
			__pretty(__rreil_pretty__, rreil_instructions_greedy, fmt, size);
			puts(fmt);
			printf("\n");

			if(options.cleanup)
				rreil_instructions_greedy = __runMonadicOneArg(__cleanup__, &state,
						rreil_instructions_greedy);
		}

		printf("RREIL instructions after LV (greedy):\n");
		__pretty(__rreil_pretty__, rreil_instructions_greedy, fmt, size);
		puts(fmt);
		printf("\n");

		for(size_t i = 0; fmt[i]; i++)
			if(fmt[i] == '\n')
				lines_greedy++;

		__resetHeap();
		consumed += __getBlobIndex(state) - consumed;

		//printf("consumed: %lu, buffer_length: %lu\n", consumed, buffer_length);
	}

	if(native_instructions)
		native_instructions--;

	printf("Statistics:\n");
	printf("Number of native instructions: %zu\n", native_instructions);
	printf("Number of lines without LV analysis: %zu\n", lines);
	printf("Number of lines with LV analysis: %zu\n", lines_greedy);

	double reduction = 1 - (lines_greedy / (double)lines);

	printf("Reduction: %lf%%\n", 100 * reduction);

	printf(
			"Time needed for the decoding and the translation to RREIL: %lf seconds\n",
			time_non_opt / (double)(1000000000));
	printf("Time needed for the lv analysis: %lf\n seconds",
			time_opt / (double)(1000000000));

	end: free(buffer);
	free(fmt);

	return (1);
}

