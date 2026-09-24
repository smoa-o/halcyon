#include "kernel/libcyon.h"
#include "kernel/libcyon0.h"

void umain(void);

void kmain(void) {
	*((unsigned char*)0x601) = 0xff;
	kernelmain(); // on kernelmain
	SwitchToRing3();
	umain(); // on umain
}

void umain(void) {
	usermain();
	for (;;);
}
