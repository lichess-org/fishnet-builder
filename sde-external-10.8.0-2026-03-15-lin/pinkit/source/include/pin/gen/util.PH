/*
 * Copyright (C) 2020-2025 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifdef PIN_G_UTIL_PH
#error duplicate inclusion of util
#else
#define PIN_G_UTIL_PH
/*! @file
 * This module contains useful utility functions.
 */

/*! @ingroup UTILS
  ctype::isspace alternative (avoids complications from including ctype.h).
*/
extern BOOL CharIsSpace(CHAR c);

/*! @ingroup UTILS
    ctype::toupper alternative (avoids complications from including ctype.h).
*/
extern CHAR CharToUpper(CHAR c);

/*! @ingroup UTILS
  Print pointer.
 */
extern std::string ptrstr(const VOID* val);

/*! @ingroup UTILS
  Convert a ADDRINT into a string using the hex address format.
 */
extern std::string StringFromAddrint(ADDRINT l);

/*! @ingroup UTILS
  Convert a UINT64 into a string using the hex address format.
 */
extern std::string StringFromUint64(UINT64 l);

/*! @ingroup UTILS
  Convert a UINT64 into a dec string. Padding can be specified as well.
 */
extern std::string StringDec(UINT64 l, UINT32 digits, CHAR padding);

/*! @ingroup UTILS
  Convert a INT64 into a dec string. Padding can be specified as well.
 */
extern std::string StringDecSigned(INT64 l, UINT32 digits, CHAR padding);

/*! @ingroup UTILS
  Convert a INT64 into a dec string with 1000 separation . Padding can be specified as well.
 */
extern std::string StringBignum(INT64 l, UINT32 digits, CHAR padding);

/*! @ingroup UTILS
  Add new lines to string to make it fit given line width restrictions.
 */
extern std::string Reformat(const std::string& s, const std::string& prefix, UINT32 min_line, UINT32 max_line);

/*! @ingroup UTILS
  Convert a UINT32 into a hex string. Padding can be specified as well.
 */
extern std::string StringHex32(UINT32 l, UINT32 digits, BOOL prefix_0x);

/*! @ingroup UTILS
  Convert a BOOL into a string.
 */
extern std::string StringBool(BOOL b);

/*! @ingroup UTILS
  Convert a TRI into a string.
 */
extern std::string StringTri(TRI t);

/*! @ingroup UTILS
  Convert a string to an INT32.
 */
extern INT32 Int32FromString(const std::string& s);

/*! @ingroup UTILS
  Convert a string to a UINT32.
 */
extern UINT32 Uint32FromString(const std::string& s);

/*! @ingroup UTILS
  Convert a string to an INT64.
 */
extern INT64 Int64FromString(const std::string& s);

/*! @ingroup UTILS
  Convert a string to a UINT64.
 */
extern UINT64 Uint64FromString(const std::string& s);

/*! @ingroup UTILS
  Convert a string to a FLT64.
 */
extern FLT64 FLT64FromString(const std::string& s);

/*! @ingroup UTILS
 * Convert specified character to the corresponding hexadecimal digit.
 * @return integer in the interval [0, 15] or -1 upon failure
 */
extern INT CharToHexDigit(CHAR c);

/*! @ingroup UTILS
  Convert a string to an ADDRINT.
 */
extern ADDRINT AddrintFromString(const std::string& str);

/*! @ingroup UTILS
  Read a line from file while maintaining a current line count
  skipping over blank and comment lines.
 */
extern std::string ReadLine(std::istream& inputFile, UINT32* lineNum);

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string StringHex(UINT32 l, UINT32 digits, BOOL prefix_0x = TRUE) { return StringHex32(l, digits, prefix_0x); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(INT64 val, UINT32 width = 0) { return StringDecSigned(val, width, ' '); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(INT32 val, UINT32 width = 0) { return StringDecSigned(val, width, ' '); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(INT16 val, UINT32 width = 0) { return StringDecSigned(val, width, ' '); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(UINT64 val, UINT32 width = 0) { return StringDec(val, width, ' '); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(UINT32 val, UINT32 width = 0) { return StringDec(val, width, ' '); }

/*! @ingroup UTILS
  Create a string containing the given decimal integer.
 */
inline std::string decstr(UINT16 val, UINT32 width = 0) { return StringDec(val, width, ' '); }

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(INT64 val, UINT32 width = 0)
{
    std::string ostr;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    ostr = StringHex(INT32((val >> 16) >> 16), width);
#else
    ostr = StringHex(INT32(val >> 32), width);
#endif
    ostr += StringHex(UINT32(val), 8, FALSE);

    return ostr;
}

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(INT32 val, UINT32 width = 0) { return StringHex(INT32(val), width); }

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(INT16 val, UINT32 width = 0) { return StringHex(INT32(val), width); }

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(UINT64 val, UINT32 width = 0)
{
    std::string ostr;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    ostr = StringHex(UINT32((val >> 16) >> 16), width);
#else
    ostr = StringHex(UINT32(val >> 32), width);
#endif
    ostr += StringHex(UINT32(val), 8, FALSE);

    return ostr;
}

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(VOID* p, UINT32 width = 0)
{
#if defined(HOST_IA32E)
    UINT64 val = reinterpret_cast< UINT64 >(p);
    return hexstr(val, width);
#else
    UINT32 val = reinterpret_cast< UINT32 >(p);
    return StringHex(val, width);
#endif
}

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(const VOID* p, UINT32 width = 0)
{
#if defined(HOST_IA32E)
    UINT64 val = reinterpret_cast< UINT64 >(p);
    return hexstr(val, width);
#else
    UINT32 val = reinterpret_cast< UINT32 >(p);
    return StringHex(val, width);
#endif
}

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(UINT32 val, UINT32 width = 0) { return StringHex(UINT32(val), width); }

/*! @ingroup UTILS
  Create a string with a hexadecimal prefix containing the given hexadecimal integer.
 */
inline std::string hexstr(UINT16 val, UINT32 width = 0) { return StringHex(UINT32(val), width); }

/*! @ingroup UTILS
  Left justify string.
 */
inline std::string ljstr(const std::string& s, UINT32 width, CHAR padding = ' ')
{
    std::string ostr(width, padding);
    ostr.replace(0, s.length(), s);
    return ostr;
}

/*! @ingroup UTILS
  Decimal-to-string conversion object.
 */
struct DECSTR
{
    DECSTR(UINT32 width = 0) : _w(width) {}
    template< typename T > std::string operator()(const T& t) const { return decstr(t, _w); }
    UINT32 _w;
};

/*! @ingroup UTILS
  Hexadecimal-to-string conversion object.
 */
struct HEXSTR
{
    HEXSTR(UINT32 width = 0) : _w(width) {}
    template< typename T > std::string operator()(const T& t) const { return hexstr(t, _w); }
    UINT32 _w;
};

/*! @ingroup UTILS
  popcount/bitcount code using the usual trick
 */
extern UINT32 BitCount(ADDRINT val);

/*! @ingroup UTILS
    Convert ADDRINT to "void *"
 */
inline VOID* Addrint2VoidStar(ADDRINT addr)
{
#if defined(HOST_IA32E) && defined(TARGET_IA32)
    ASSERT(false, "Should not be called in cross environment\n");
    return 0;
#else
    return reinterpret_cast< VOID* >(addr);
#endif
}

/*! @ingroup UTILS
  Convert "void *" to ADDRINT.
 */
inline ADDRINT VoidStar2Addrint(const VOID* addr)
{
#if defined(HOST_IA32E) && defined(TARGET_IA32)
    ASSERT(false, "Should not be called in cross environment\n");
    return 0;
#else
    return reinterpret_cast< ADDRINT >(addr);
#endif
}

/*! @ingroup UTILS
  Convert "void *" to ADDRINT
 */
inline ADDRINT VoidStar2Addrint(VOID* addr)
{
#if defined(HOST_IA32E) && defined(TARGET_IA32)
    ASSERT(false, "Should not be called in cross environment\n");
    return 0;
#else
    return reinterpret_cast< ADDRINT >(addr);
#endif
}

/*! @ingroup UTILS
 * Round integer of type <T> up to given alignment.
 */
template< typename T > T RoundUp(T value, size_t alignment)
{
    if (alignment == 0)
    {
        return value;
    }

    value += T(alignment - 1);
    value /= T(alignment);
    value *= T(alignment);

    return value;
}

/*! @ingroup UTILS
 * Specialization of the RoundUp function for pointer type
 */
template< typename T > T* RoundUp(T* ptr, size_t alignment)
{
    return (reinterpret_cast< T* >(RoundUp(reinterpret_cast< ADDRINT >(ptr), alignment)));
}

/*! @ingroup UTILS
 * Round integer of type <T> down to given alignment.
 */
template< typename T > T RoundDown(T value, size_t alignment)
{
    if (alignment == 0)
    {
        return value;
    }

    value /= T(alignment);
    value *= T(alignment);

    return value;
}

/*! @ingroup UTILS
 * Specialization of the RoundDown function for pointer type
 */
template< typename T > T* RoundDown(T* ptr, size_t alignment)
{
    return (reinterpret_cast< T* >(RoundDown(reinterpret_cast< ADDRINT >(ptr), alignment)));
}

/*! @ingroup UTILS
    Get the page size of the OS abstraction layer
 */
constexpr inline ADDRINT GetPageSize() noexcept
{
    return 4096; // When using PINOS Page Size is always 4K
}

/*! @ingroup UTILS
    Get the address of the page that addr is in
 */
constexpr inline ADDRINT GetPageOfAddr(ADDRINT addr) noexcept
{
    return addr & ~(GetPageSize() - 1);
}

#if !defined(TARGET_WINDOWS)

/*! @ingroup UTILS
   Concatenate two strings with a path delimiter
 */
extern std::string Joinpath(std::string s1, std::string s2);

/*! @ingroup UTILS
   Create a temporary file name
 */
extern CHAR* CreateTmpFileName(const CHAR* fnameTemplate, const UINT32 fnameTemplateSize);

#endif

/*! @ingroup UTILS
  @return current stack pointer
*/
extern const VOID* GetSp();

/*! @ingroup UTILS
  Return offset, in bytes, of <ptr1> from <ptr2>
 */
inline size_t PtrDiff(const VOID* ptr1, const VOID* ptr2)
{
    return (reinterpret_cast< const INT8* >(ptr1) - reinterpret_cast< const INT8* >(ptr2));
}

/*! @ingroup UTILS
  Return pointer whose offset, in bytes, from <ptr> is <offset>
 */
inline VOID* PtrAtOffset(VOID* ptr, size_t offset) { return (reinterpret_cast< INT8* >(ptr) + offset); }

/*! @ingroup UTILS
  Return pointer whose offset, in bytes, from <ptr> is <-offset>
 */
inline VOID* PtrMinusOffset(VOID* ptr, size_t offset) { return (reinterpret_cast< INT8* >(ptr) - offset); }

/*! @ingroup UTILS
  Return const pointer whose offset, in bytes, from <ptr> is <offset>
 */
inline const VOID* PtrAtOffset(const VOID* ptr, size_t offset) { return (reinterpret_cast< const INT8* >(ptr) + offset); }

/*! @ingroup UTILS
  Return pointer of type <T> whose offset, in bytes, from <ptr> is <offset>
 */
template< typename T > T* PtrAtOffset(VOID* ptr, size_t offset) { return (reinterpret_cast< T* >(PtrAtOffset(ptr, offset))); }

/*! @ingroup UTILS
  Return const pointer of type <T> whose offset, in bytes, from <ptr> is <offset>
 */
template< typename T > const T* PtrAtOffset(const VOID* ptr, size_t offset)
{
    return (reinterpret_cast< const T* >(PtrAtOffset(ptr, offset)));
}

/*! @ingroup UTILS
 *  Template POD structure that optionally keeps a value of type <T>.
 *  @tparam  T   the value type
 */
template< typename T > struct OPTIONAL_VALUE
{
    BOOL m_hasValue; ///< TRUE, if a value has been assigned to this object
    T m_value;       ///< The value assigned to this object

    /*!
     * Assign the specified value to this object.
     * @param[in]   value  the new value to be assigned to this object
     */
    VOID Set(const T& value)
    {
        m_hasValue = TRUE;
        m_value    = value;
    }

    /*!
     * Assign a value to this object or remove the previous assignment.
     * @param[in]   pValue  pointer to the new value to be assigned to this object or
     *                      NULL to remove the previous assignment
     */
    VOID Set(const T* pValue)
    {
        if (pValue != 0)
        {
            Set(*pValue);
        }
        else
        {
            Reset();
        }
    }

    /*!
     * Remove the previous value assignment, if any.
     */
    VOID Reset() { m_hasValue = FALSE; }

    /*!
     * Get the value of this object, if previously assigned.
     * @param[out] pValue   optional pointer to variable that receives the value assigned to
     *                      this object, if any
     * @return TRUE if a value has been assigned to this object.
     */
    BOOL Get(T* pValue) const
    {
        if (m_hasValue && (pValue != 0))
        {
            *pValue = m_value;
        }
        return m_hasValue;
    }

    /*!
     * @return TRUE if a value has been assigned to this object.
     */
    BOOL HasValue() const { return m_hasValue; }

    /*!
     * @return reference to the value assigned to this object.
     * The caller must ensure that a value has already been assigned to this object.
     */
    T& Value() { return m_value; }
    const T& Value() const { return m_value; }

    /*!
     * Get a pointer to the value of this object, if the value has been assigned.
     * @return pointer to the value kept in this object or NULL if no value has been
     *         assigned to this object.
     */
    T* ValuePtr() { return ((m_hasValue) ? &m_value : 0); }
    const T* ValuePtr() const { return ((m_hasValue) ? &m_value : 0); }
};

/*! @ingroup UTILS
  Convert a FLT64 into a string. Padding can be specified as well.
 */
extern std::string StringFlt(FLT64 val, UINT32 precision, UINT32 width);

/*! @ingroup UTILS
  Create a string containing the given floating point number.
 */
inline std::string fltstr(FLT64 val, UINT32 prec = 0, UINT32 width = 0) { return StringFlt(val, prec, width); }

/*! @ingroup UTILS
  Floating-to-string conversion object.
 */
struct FLTSTR
{
    FLTSTR(UINT32 prec = 0, UINT32 width = 0) : _p(prec), _w(width) {}
    template< typename T > std::string operator()(const T& t) const { return fltstr(t, _p, _w); }
    UINT32 _p;
    UINT32 _w;
};

#endif // PIN_G_UTIL_PH
