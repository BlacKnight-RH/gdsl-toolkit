#include <stdio.h>
#include <stdlib.h>

void __exit() {
	exit(0);
}

int main(void) {
	FILE *f = fopen("example.bin", "w");
	if(!f)
		return 1;
	
	for(void *i = &&start; i < &&end; i++)
		fwrite(i, 1, 1, f);

	fclose(f);

	__exit();

	start:
	asm (
"mov $0x9988776655443322, %rax\n"
"mov $0xabcdef01, %ebx\n"
"mov %bh, %ah\n"
"jmp %rax\n"
);
	end:;

	return 0;
}
