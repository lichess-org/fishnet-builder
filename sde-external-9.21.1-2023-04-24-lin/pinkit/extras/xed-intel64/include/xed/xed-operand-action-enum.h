/* BEGIN_LEGAL 

Copyright (c) 2023 Intel Corporation

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  
END_LEGAL */
/// @file xed-operand-action-enum.h

// This file was automatically generated.
// Do not edit this file.

#if !defined(XED_OPERAND_ACTION_ENUM_H)
# define XED_OPERAND_ACTION_ENUM_H
#include "xed-common-hdrs.h"
#define XED_OPERAND_ACTION_INVALID_DEFINED 1
#define XED_OPERAND_ACTION_RW_DEFINED 1
#define XED_OPERAND_ACTION_R_DEFINED 1
#define XED_OPERAND_ACTION_W_DEFINED 1
#define XED_OPERAND_ACTION_RCW_DEFINED 1
#define XED_OPERAND_ACTION_CW_DEFINED 1
#define XED_OPERAND_ACTION_CRW_DEFINED 1
#define XED_OPERAND_ACTION_CR_DEFINED 1
#define XED_OPERAND_ACTION_LAST_DEFINED 1
typedef enum {
  XED_OPERAND_ACTION_INVALID,
  XED_OPERAND_ACTION_RW, ///< Read and written (must write)
  XED_OPERAND_ACTION_R, ///< Read-only
  XED_OPERAND_ACTION_W, ///< Write-only (must write)
  XED_OPERAND_ACTION_RCW, ///< Read and conditionlly written (may write)
  XED_OPERAND_ACTION_CW, ///< Conditionlly written (may write)
  XED_OPERAND_ACTION_CRW, ///< Conditionlly read, always written (must write)
  XED_OPERAND_ACTION_CR, ///< Conditional read
  XED_OPERAND_ACTION_LAST
} xed_operand_action_enum_t;

/// This converts strings to #xed_operand_action_enum_t types.
/// @param s A C-string.
/// @return #xed_operand_action_enum_t
/// @ingroup ENUM
XED_DLL_EXPORT xed_operand_action_enum_t str2xed_operand_action_enum_t(const char* s);
/// This converts strings to #xed_operand_action_enum_t types.
/// @param p An enumeration element of type xed_operand_action_enum_t.
/// @return string
/// @ingroup ENUM
XED_DLL_EXPORT const char* xed_operand_action_enum_t2str(const xed_operand_action_enum_t p);

/// Returns the last element of the enumeration
/// @return xed_operand_action_enum_t The last element of the enumeration.
/// @ingroup ENUM
XED_DLL_EXPORT xed_operand_action_enum_t xed_operand_action_enum_t_last(void);
#endif