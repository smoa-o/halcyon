#include "kernel/libcyon.h"
#include "kernel/libcyon0.h"

void usermain();

void kmain() {
	*((unsigned char*)0x601) = 0xff;
	ConvertRing(0x18 | 3, 0x7c00, 0x20 | 3, (unsigned int)&usermain);
	// on usermain
}

void usermain() {
	for (;;);
}
