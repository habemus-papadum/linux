#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <asm/unistd.h>

#ifndef __NR_demo_strlen
#error "__NR_demo_strlen is missing; install headers from this kernel tree first."
#endif

static long call_demo_strlen(const char *msg, size_t maxlen)
{
	long ret = syscall(__NR_demo_strlen, msg, maxlen);

	if (ret == -1) {
		int err = errno;

		fprintf(stderr, "[init] demo_strlen(\"%s\", %zu) failed: %s\n",
			msg, maxlen, strerror(err));
		return -err;
	}

	return ret;
}

int main(int argc, char **argv)
{
	const char *msg = argc > 1 ? argv[1] : "hello from demo init";
	const char *long_msg = "abcdefghijklmnopqrstuvwxyz0123456789"
			       "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	size_t maxlen = argc > 2 ? strtoul(argv[2], NULL, 0) : 64;
	unsigned int iteration = 0;

	puts("[init] demo init process starting");

	for (;;) {
		long len = call_demo_strlen(msg, maxlen);
		long clipped = call_demo_strlen(long_msg, 16);

		printf("[init] #%u demo_strlen(\"%s\", max=%zu) -> %ld\n",
		       iteration, msg, maxlen, len);
		printf("[init] #%u demo_strlen(long_msg, max=%d) -> %ld\n",
		       iteration, 16, clipped);
		fflush(stdout);
		sleep(1);
		iteration++;
	}
}
