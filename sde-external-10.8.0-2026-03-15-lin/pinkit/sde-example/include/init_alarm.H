/*
 * Copyright (C) 2014-2024 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifndef _INIT_ALARM_H_
#define _INIT_ALARM_H_

#include "pin.H"
#include <set>

namespace CONTROLLER
{
class CONTROL_MANAGER;

class INIT_ALARM
{
  public:
    INIT_ALARM() : _manager(NULL), _thread_start_tls_key(INVALID_TLS_KEY), _disabled(FALSE) {}
    VOID Activate(CONTROL_MANAGER* manager);
    VOID Disable() { _disabled = TRUE; }

  private:
    CONTROL_MANAGER* _manager;
    TLS_KEY _thread_start_tls_key;
    std::set<ADDRINT> _thread_first_ip;
    volatile BOOL _disabled;

    static VOID OnTrace(TRACE trace, VOID* vthis);
    static VOID ThreadStart(THREADID tid, CONTEXT* ctxt, INT32 flags, VOID* v);

    // use TLS to notify if we should start the thread
    static inline ADDRINT ShouldStart(INIT_ALARM* init_alarm, THREADID tid)
    {
        VOID* tls_data       = PIN_GetThreadData(init_alarm->_thread_start_tls_key, tid);
        ADDRINT start_thread = reinterpret_cast<ADDRINT>(tls_data);
        return (start_thread & (!init_alarm->_disabled));
    }

    static VOID Start(CONTEXT* ctxt, ADDRINT ip, THREADID tid, VOID* vthis);
};

} // namespace CONTROLLER
#endif
