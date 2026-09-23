#include "kernel/libcyon.h"

void kmain(void) {
	*((unsigned char*)0x601) = 0xff;
	Halt();
}
