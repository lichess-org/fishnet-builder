/*
 * Copyright (C) 2009-2024 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#include <sched.h>
#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>

#define MAXTHREADS 1000

int data[MAXTHREADS];

void* start(void* arg)
{
    int i = 0;
    for (i = 0; i < 1000; i++)
    {
        void* h = malloc(13);
        if (h) free(h);
    }
    return 0;
}

static void create_threads(int numthreads, int createDetached, pthread_t* threads)
{
    int i;
    pthread_attr_t attr;

    // Initialize the thread attribute
    if (pthread_attr_init(&attr) != 0) {
        perror("pthread_attr_init");
        exit(1);
    }

    if(createDetached)
    {
        // Set the thread attribute to create the thread in a detached state
        if (pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED) != 0) {
            perror("pthread_attr_setdetachstate");
            pthread_attr_destroy(&attr);
            exit(1);
        }
    }

    for (i = 0; i < numthreads; i++)
    {
        pthread_create(&threads[i], &attr, start, 0);
        if(createDetached)
        {
            usleep(1000); // Allow some delay so threads can finish and TLS by glibc recycled
        }
    }

    pthread_attr_destroy(&attr);
}



int main(int argc, char* argv[])
{
    pthread_t threads[MAXTHREADS];
    int i;
    int numthreads = (2 <= argc) ? atoi(argv[1]) : 20;
    int createDetached = (3 == argc) ? atoi(argv[2]) : 0;

    if(numthreads < 1 || numthreads > MAXTHREADS)
    {
        numthreads = 20;
    }

    printf("Creating %d threads\n", numthreads);

    create_threads(numthreads, createDetached, threads);

    if(createDetached)
    {
        usleep(numthreads * 5000); // Give threads time to finish
    }
    else
    {
        for (i = 0; i < numthreads; i++)
        {
            pthread_join(threads[i], 0);
        }
    }

    printf("All threads joined\n");

    return 0;
}
