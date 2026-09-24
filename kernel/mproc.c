#include "kernel/libcyon.h"
#include "kernel/libcyon0.h"

void usermain(void);

void kmain(void) {
	*((unsigned char*)0x601) = 0xff;
	kernelmain(); // on kernelmain
	SwitchToRing3();
	usermain(); // on usermain
}

void usermain(void) {
	for (;;);
}
