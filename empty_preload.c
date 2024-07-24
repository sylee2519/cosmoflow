#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <stdarg.h>

// Constructor function to print a message when the library is loaded
__attribute__((constructor)) void preload_constructor() {
    printf("Empty LD_PRELOAD shared library loaded.\n");
}

// Override a sample function (e.g., printf) to do nothing
int printf(const char *format, ...) {
    // Get the original printf function
    static int (*real_printf)(const char *, ...) = NULL;
    if (!real_printf) {
        real_printf = (int (*)(const char *, ...))dlsym(RTLD_NEXT, "printf");
    }

    va_list args;
    va_start(args, format);
    int result = real_printf(format, args);
    va_end(args);

    return result;
}

