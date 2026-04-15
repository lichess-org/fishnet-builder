/*
 * Copyright (C) 2025-2025 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */
#ifndef PIN_G_TIME_EMULATION_PH
#define PIN_G_TIME_EMULATION_PH

//Time Emulation API
/// @cond INTERNAL_DOXYGEN
/*! @ingroup TIME_EMULATION
 * Get the current time in nanoseconds.
 *
 * @param[in]   id      The clock ID to get the time from.
 * @param[out]  ts      Pointer to a timespec structure to hold the time.
 * @param[in]   tid     Id of the calling thread. If ID is not TE_THREAD_TIME, tid is ignored.
 *
 * @note    Use this function only when Time Emulation is enabled.
 */
extern VOID TE_GetTime(TE_CLOCK_ID id, TE_timespec* ts, THREADID tid = INVALID_THREADID);

/*! @ingroup TIME_EMULATION
 * Get the emulated TSC from Time Emulation.
 *
 * @return  emulated TSC.
 * @note    Use this function only when Time Emulation is enabled.
 */
extern UINT64 TE_GetEmulatedTSC();

/*! @ingroup TIME_EMULATION
 * Get the IPC from Time Emulation.
 *
 * @return  THE IPC.
 * @note    Use this function only when Time Emulation is enabled.
 */
extern FLT32 TE_GetIPC();

/*! @ingroup TIME_EMULATION
 * Get the TSC frequency from Time Emulation.
 *
 * @return  TSC frequency.
 * @note    Use this function only when Time Emulation is enabled.
 */
extern UINT64 TE_GetTscFreq();
/// @endcond
#endif // PIN_G_TIME_EMULATION_PH