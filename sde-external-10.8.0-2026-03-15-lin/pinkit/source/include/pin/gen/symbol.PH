/*
 * Copyright (C) 2020-2026 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifdef PIN_G_SYMBOL_PH
#error duplicate inclusion of symbol PH
#else
#define PIN_G_SYMBOL_PH
/*! @file
    Defines APIs for manipulating symbols in binaries, supporting both PE (Windows) and ELF (Linux) formats.
*/

/*! @ingroup PIN_CONTROL
  Initialize symbol table code. Pin does not read symbols unless this function or PIN_InitSymbolsAlt is called.
  Must be called before @ref PIN_StartProgram

  @par Availability:
  \b Mode:  JIT & Probe\n
  \b O/S:   Linux, Windows\n
  \b CPU:   All\n
*/
extern VOID PIN_InitSymbols();

/*! @ingroup PIN_CONTROL
  Initialize symbol table code with an explicitly specified mode of symbol support. \n
  Pin does not read symbols unless this function or PIN_InitSymbols are called. \n
  Must be called before @ref PIN_StartProgram. \n
  Alternative to PIN_InitSymbols() on Windows & Linux. \n

  @param[in]  mode  Explicit mode of symbol support. See @ref SYMBOL_INFO_MODE for details. \n

  @note On Windows, when requesting debug symbols, if debug symbols are present, and the
        binary is linked with incremental linking, exported symbols may point to ILT (Incremental Link
        Table) thunks rather than the actual function implementations. Pin detects such thunks and
        renames the corresponding symbols by appending "@ILT" to avoid conflicts with debug info symbols
        which point to the actual implementations.                             

  @return     TRUE if the operation succeeded \n

  @par Availability:
  \b Mode:  JIT & Probe\n
  \b O/S:   Windows, Linux\n
  \b CPU:   All\n
*/
extern BOOL PIN_InitSymbolsAlt(SYMBOL_INFO_MODE mode);
#endif // PIN_G_SYMBOL_PH