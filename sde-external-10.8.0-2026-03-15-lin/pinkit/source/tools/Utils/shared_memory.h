/*
 * Copyright (C) 2023-2023 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifndef _SHARED_MEMORY_H_
#define _SHARED_MEMORY_H_

/* @file
 * Utility for sharing a memory object between application running under Pin and the tool that is running in the same process.
 * And between other processes as well.
 *
 * @note Currently only one object can be created per session.
 */

#include <unistd.h>

/*!
 * Create shared object based on specified pid. Normally pid will be the PID of the process that created this object.
 * Return pointer to the shared object.
 * @note Currently there can only be only one shared single object (between different processes or even in the same process).
 * @note This should be called only once per "session"
 *
 * param[in]    objectSize  Size of object that needs to be allocated.
 * param[in]    pid         This needs to be unique for all objects users on all processes.
 *
 * @return  pointer to the shared object (which is an address to the allocate memory)
 *          Users should cast this pointer to the type of object they need.
 *
 */
void* create_shared_object(size_t objectSize, pid_t pid);

/*!
 * Get the already created single shared object based on the specified pid which should be the
 * PID of the process that created this object.
 * @note Currently there can only be only one shared single object (between different processes or even in the same process).
 * @note Can be called multiple times
 *
 * param[in]    objectSize  Size of object
 * param[in]    pid         This needs to be unique for all objects users on all processes.
 *
 */
void* get_shared_object(size_t objectSize, pid_t pid);

/**
 * Delete shared object. Object can no longer be used after this point.
 * @return  true if shared memory object was successfully deleted. False otherwise.
 */
bool remove_shared_object(pid_t pid);

#endif // _SHARED_MEMORY_H_
