#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include "scaldate.h"
#include "version.h"

#if !defined(PROGRAM_NAME)
#define PROGRAM_NAME datetojul
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
static int usage(void)
{
    printf("  Usage: %s <YYYY2> <MM2> <DD2> <YYYY1> <MM1> <DD1>\n", PROGRAM_NAME);
    printf("         %s <YYYYMMDD2> <YYYYMMDD1>\n", PROGRAM_NAME);
    printf("         %s -v\n", PROGRAM_NAME);
    exit(1);
}

int main(int argc, char* argv[])
{
    unsigned int y2, m2, d2, y1, m1, d1;
    long int dn2, dn1;

    if (argc == 2 && strcmp(argv[1], "-v") == 0) {
        printf("  %s v%s\n", PROGRAM_NAME, VERSION);
        return 0;
    } else if (argc != 3 && argc != 7)
        usage();

    if (argc == 3) {
        if (strlen(argv[1]) != 8)
            quit("the parameter \"%s\" is not in YYYYMMDD format", argv[1]);
        if (strlen(argv[2]) != 8)
            quit("the parameter \"%s\" is not in YYYYMMDD format", argv[2]);
        if (sscanf(argv[1], "%4u%2u%2u", &y2, &m2, &d2) != 3)
            quit("could not extract Y,M,D  from \"%s\"", argv[1]);
        if (sscanf(argv[2], "%4u%2u%2u", &y1, &m1, &d1) != 3)
            quit("could not extract Y,M,D  from \"%s\"", argv[2]);
    } else if (argc == 7) {
        if (!str2uint(argv[1], &y2))
            quit("could not convert \"%s\" to int", argv[1]);
        if (!str2uint(argv[2], &m2))
            quit("could not convert \"%s\" to int", argv[2]);
        if (!str2uint(argv[3], &d2))
            quit("could not convert \"%s\" to int", argv[3]);
        if (!str2uint(argv[4], &y1))
            quit("could not convert \"%s\" to int", argv[4]);
        if (!str2uint(argv[5], &m1))
            quit("could not convert \"%s\" to int", argv[5]);
        if (!str2uint(argv[6], &d1))
            quit("could not convert \"%s\" to int", argv[6]);
    } else
        quit("programming error");

    dn2 = ymd_to_scalar(y2, m2, d2);
    dn1 = ymd_to_scalar(y1, m1, d1);

    printf("%ld\n", dn2 - dn1);

    return 0;
}
