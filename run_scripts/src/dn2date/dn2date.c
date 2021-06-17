#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include "scaldate.h"
#include "version.h"

#if !defined(PROGRAM_NAME)
#define PROGRAM_NAME "dn2date"
#endif

/**
 */
static void quit(char* format, ...)
{
    va_list args;

    fflush(stdout);

    fprintf(stderr, "\n  error: %s: ", PROGRAM_NAME);
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, "\n\n");
    exit(1);
}

/**
 */
static int str2uint(char* token, unsigned int* value)
{
    long int tmp;
    char* end = NULL;

    if (token == NULL) {
        *value = UINT_MAX;
        return 0;
    }

    tmp = strtol(token, &end, 10);

    if (end == token || tmp > UINT_MAX || tmp < 0) {
        *value = UINT_MAX;
        return 0;
    }

    *value = (unsigned int) tmp;
    return 1;
}

/**
 */
static int str2lint(char* token, long int* value)
{
    long int tmp;
    char* end = NULL;

    if (token == NULL) {
        *value = LONG_MAX;
        return 0;
    }

    tmp = strtol(token, &end, 10);

    if (end == token || tmp > INT_MAX || tmp < INT_MIN) {
        *value = LONG_MAX;
        return 0;
    }

    *value = tmp;
    return 1;
}

/**
 */
static int usage(void)
{
    printf("  Usage: %s <day number> <YYYY> <MM> <DD>\n", PROGRAM_NAME);
    printf("         %s <day number> <YYYYMMDD>\n", PROGRAM_NAME);
    printf("         %s -v\n", PROGRAM_NAME);
    exit(1);
}

int main(int argc, char* argv[])
{
    long int daydiff;
    unsigned int y, m, d;
    long int dn;

    if (argc == 2 && strcmp(argv[1], "-v") == 0) {
        printf("  %s v%s\n", PROGRAM_NAME, VERSION);
        return 0;
    } else if (argc != 3 && argc != 5)
        usage();

    if (argc == 3) {
        if (strlen(argv[2]) != 8)
            quit("the parameter \"%s\" is not in YYYYMMDD format", argv[2]);
        if (!str2lint(argv[1], &daydiff))
            quit("could not convert \"%s\" to int", argv[1]);
        if (sscanf(argv[2], "%4u%2u%2u", &y, &m, &d) != 3)
            quit("could not extract Y,M,D  from \"%s\"", argv[2]);
    } else if (argc == 5) {
        if (!str2lint(argv[1], &daydiff))
            quit("could not convert \"%s\" to int", argv[1]);
        if (!str2uint(argv[2], &y))
            quit("could not convert \"%s\" to int", argv[2]);
        if (!str2uint(argv[3], &m))
            quit("could not convert \"%s\" to int", argv[3]);
        if (!str2uint(argv[4], &d))
            quit("could not convert \"%s\" to int", argv[4]);
    } else
        quit("programming error");

    dn = ymd_to_scalar(y, m, d);
    scalar_to_ymd(dn + daydiff, &y, &m, &d);

    printf("%04d%02d%02d\n", y, m, d);

    return 0;
}
