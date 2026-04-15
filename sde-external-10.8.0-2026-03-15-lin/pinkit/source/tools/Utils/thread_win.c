/*
 * Copyright (C) 2006-2025 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#include <stdlib.h>
#include <stdio.h>
#include <windows.h>

#define MAXTHREADS 64

int ThreadRoutine()
{
    int i = 0;
    for (i = 0; i < 1000; i++)
    {
        void* h = malloc(13);
        if (h) free(h);
    }
    return 0;
}

int ThreadCreation(unsigned long num_threads, int createDetached)
{
    static HANDLE aThreads[MAXTHREADS] = {0};
    unsigned long slot                 = 0;
    unsigned long thread_id            = 0;
    unsigned long cnt_th               = 0;
    unsigned long thread_ret           = 0;

    fprintf(stderr, "creating %d threads \n", num_threads);

    for (cnt_th = 0; cnt_th < num_threads; cnt_th++)
    {
        aThreads[cnt_th] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadRoutine, 0, 0, (LPDWORD)&thread_id);
    }

    while (cnt_th > 0)
    {
        if (createDetached)
        {
            CloseHandle(aThreads[slot++]);
        }
        else
        {
            slot = WaitForMultipleObjects(cnt_th, aThreads, FALSE, INFINITE);
            GetExitCodeThread(aThreads[slot], &thread_ret);
            CloseHandle(aThreads[slot]);
            aThreads[slot] = aThreads[cnt_th - 1];
        }
        cnt_th--;
    }
    fprintf(stderr, "all %d threads terminated\n", num_threads);
    fflush(stderr);
    return 1;
}

int main(int argc, char* argv[])
{
    int numthreads     = (2 <= argc) ? atoi(argv[1]) : 20;
    int createDetached = (3 == argc) ? atoi(argv[2]) : 0;

    if (numthreads < 1 || numthreads > MAXTHREADS)
    {
        numthreads = 20;
    }

    printf("Creating %d threads\n", numthreads);

    ThreadCreation((unsigned long)numthreads, createDetached);
    return 0;
}
