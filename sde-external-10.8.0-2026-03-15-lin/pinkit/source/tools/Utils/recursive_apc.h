/*
 * Copyright (C) 2026-2026 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

/*! @file
 *  Reusable recursive-APC helper for Windows test applications.
 *
 *  Provides RunRecursiveApc() which queues a chain of APCs at a given
 *  depth and enters alertable waits.  Each APC handler queues the next
 *  level; at depth 2 it queues extra APCs to exercise the "multiple
 *  APCs per single wait" path.
 *
 *  An optional callback is invoked after each inner SleepEx returns,
 *  allowing callers to log or validate the return status.
 *
 *  Usage:
 *      #include "recursive_apc.h"
 *
 *      RECURSIVE_APC_CTX ctx;
 *      RunRecursiveApc(10, &ctx, NULL);   // no per-sleep callback
 *      // ctx.visits == 12  (10 recursive + 2 extras at depth 2)
 */

#ifndef RECURSIVE_APC_H
#define RECURSIVE_APC_H

#define _WIN32_WINNT 0x0400
#include <Windows.h>

#ifdef __cplusplus
extern "C"
{
#endif

    /*!
 *  Optional callback invoked after each inner SleepEx returns.
 *  @param[in] sleepExStatus  Return value from SleepEx (typically 0xC0 / WAIT_IO_COMPLETION).
 *  @param[in] depth          Recursion depth at which SleepEx was called.
 */
    typedef void (*RECURSIVE_APC_SLEEPEX_CB)(DWORD sleepExStatus, ULONG_PTR depth);

    /// Context passed through the APC chain.
    typedef struct RECURSIVE_APC_CTX_
    {
        int visits;                  ///< Total number of APC handler invocations.
        RECURSIVE_APC_SLEEPEX_CB cb; ///< Optional per-SleepEx callback (may be NULL).
    } RECURSIVE_APC_CTX;

    /* File-scope context pointer shared between RunRecursiveApc and the callback. */
    static RECURSIVE_APC_CTX* s_apcCtx = NULL;

    static VOID CALLBACK RecursiveApcProc(ULONG_PTR depth);

    /*!
 *  Run a recursive APC chain.
 *
 *  @param[in]  recursiveDepth  How many levels deep to recurse (>= 1).
 *  @param[out] pCtx            Caller-provided context; visits is zeroed
 *                              and then incremented by each APC handler.
 *  @param[in]  cb              Optional callback after each inner SleepEx (may be NULL).
 */
    static inline void RunRecursiveApc(ULONG_PTR recursiveDepth, RECURSIVE_APC_CTX* pCtx, RECURSIVE_APC_SLEEPEX_CB cb)
    {
        pCtx->visits = 0;
        pCtx->cb     = cb;
        s_apcCtx     = pCtx;

        QueueUserAPC(RecursiveApcProc, GetCurrentThread(), recursiveDepth);
        SleepEx(INFINITE, TRUE);
    }

    /*!
 *  The APC handler.  Recurses by queuing another APC and entering an
 *  alertable wait.
 */
    static VOID CALLBACK RecursiveApcProc(ULONG_PTR depth)
    {
        s_apcCtx->visits++;

        if (depth <= 1)
        {
            return; // Base case
        }

        // Queue the next level
        QueueUserAPC(RecursiveApcProc, GetCurrentThread(), depth - 1);

        if (depth == 2)
        {
            // Queue extra APCs to be delivered in the same alertable wait
            QueueUserAPC(RecursiveApcProc, GetCurrentThread(), 1);
            QueueUserAPC(RecursiveApcProc, GetCurrentThread(), 1);
        }

        DWORD status = SleepEx(INFINITE, TRUE);

        if (s_apcCtx->cb)
        {
            s_apcCtx->cb(status, depth);
        }
    }

#ifdef __cplusplus
}
#endif

#endif /* RECURSIVE_APC_H */
