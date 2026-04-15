/*
 * Copyright (C) 2023-2023 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#include "shared_memory.h"

#include <sys/mman.h>
#include <iostream>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>




/**
 * @note -
 * When sharing memory object between the Application which is running under Pin and the tool
 * which is running on the same process each will have
 * an objP of their own since the shared_memory.o is compiled once into the application and once
 * into the the tool. And they are both running on the same process.
 * So there will be two instances of shared_memory.o in the process.
 */
static void* objP = nullptr;

void* create_shared_object(size_t objectSize, pid_t pid)
{
    if (nullptr != objP)
    {
        std::cerr << "Shared memory object was already created (Currently support one time creation of shared memory). Exiting..."
             << std::endl;
    }

    // We use pid as the shared memory object unique ID.
    // So as long as all processes or multiple clients of this share memory object in the same process,
    // use the same pid as the key, they will all be able to get this object.
    // Currently only one shared memory object can be created per session.

    std::string shared_name = "/shm_pin_" + std::to_string(pid);

    // Create shared memory object
    int fd = shm_open(shared_name.c_str(), O_CREAT | O_TRUNC | O_RDWR, 0600);
    if (fd == -1)
    {
        std::cerr << "shm_open failed with errno " << errno << std::endl;
    }

    // Set it size
    if (ftruncate(fd, objectSize) == -1)
    {
        std::cerr << "ftruncate failed with errno " << errno << std::endl;
    }

    //Map the object into the caller's address space
    objP = mmap(NULL, objectSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (objP == MAP_FAILED)
    {
        std::cerr << "mmap failed with errno " << errno << std::endl;
    }

    return objP;
}

void* get_shared_object(size_t objectSize, pid_t pid)
{
    // We use pid as the shared memory object unique ID.
    // So as long as all processes or multiple clients of this share memory object in the same process,
    // use the same pid as the key, they will all be able to get this object.

    if (!objP)
    {
        std::string shared_name = "/shm_pin_" + std::to_string(pid);

        // Open the existing shared memory object
        int fd = shm_open(shared_name.c_str(), O_RDWR, 0);
        if (fd == -1)
        {
            std::cerr << "get_shared_object():shm_open failed with errno " << errno << std::endl;
        }

        // Map it into the caller's address space.
        objP = mmap(NULL, sizeof(objectSize), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (objP == MAP_FAILED)
        {
            std::cerr << "get_shared_object():mmap failed with errno " << errno << std::endl;
        }
    }
    return objP;
}

bool remove_shared_object(pid_t pid)
{
    std::string shared_name = "/shm_pin_" + std::to_string(pid);

    // Delete object
    int ret = shm_unlink(shared_name.c_str());

    if (ret == -1)
    {
        std::cerr << "shm_unlink failed with errno " << errno << std::endl;
        return false;
    }

    return true;
}
