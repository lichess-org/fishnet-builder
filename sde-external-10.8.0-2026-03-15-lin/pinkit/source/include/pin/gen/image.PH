/*
 * Copyright (C) 2020-2026 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifdef PIN_G_IMAGE_PH
#error duplicate inclusion of image
#else
#define PIN_G_IMAGE_PH
/*! @file
    Static model for instrumenting IMG's once they are loaded into memory.
*/

/**
 * @ingroup IMG REPLAY
 * @brief Returns a IMG object for image loaded outside of PIN's loader.
 *
 * Tool should use this IMG object to mark the routines inside it, using RTN_CreateAt().
 * After all the routines are marked, tool should call IMG_ReplayImageLoad() to finalize the image
 * load procedure.
 *
 * @param[in] filename       name of the image visible to Pin tools
 * @param[in] start          memory address where first byte of the image is loaded to
 * @param[in] size           the size of the image in memory. This means that the image region in memory
 *                        will be at [start .. start+size)
 * @param[in] loadOffset     the offset between the memory addresses specified in the executable/library
 *                        files and the memory addresses where this image was actaully loaded
 * @param[in] mainExecutable  TRUE if this is the main image
 *
 * @return               IMG object that represents the image. Please make sure to call IMG_ReplayImageLoad()
 *                        on the IMG object after you're done creating all the routines in the IMG object.
 *
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   All\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_CreateAt(const char* filename, ADDRINT start, USIZE size, ADDRINT loadOffset, BOOL mainExecutable);

/**
 * @ingroup IMG REPLAY
 * @brief Replays the image load of an IMG object (created by IMG_CreateAt()).
 *
 * This means that all the image load callbacks will be called for the
 * specified IMG object.
 * If PIN_StartProgram() wasn't called yet, PIN will enqueue this request and
 * will process this request after PIN_StartProgram() was called
 *
 * @param[in] img            The image object to replay its load
 *
 * @note The vm and pin client locks are obtained during the call of this API.
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   All\n
 * \b CPU:   All\n
 *
 */
extern VOID IMG_ReplayImageLoad(IMG img);

/**
 * @ingroup IMG REPLAY APPDEBUG
 * @brief Gets a read-only copy of loader information for the image which is used in PIN ADX debugger.
 *
 * @param[in] img            The image object to act on
 *
 * @return               Pointer to OS specific structure that holds data about loader information.
 *                        On Linux, this is a pointer to struct LINUX_LOADER_IMAGE_INFO.
 *
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern VOID* IMG_GetLoaderInfo(IMG img);

/**
 * @ingroup IMG REPLAY APPDEBUG
 * @brief Sets the loader information for the image which are used in PIN ADX debugger.
 *
 * @param[in] img            The image object to act on
 * @param[in] loaderInfo     Points to OS specific structure that holds data about loader information.
 *                        On Linux, this is a pointer to struct LINUX_LOADER_IMAGE_INFO.
 *
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern VOID IMG_SetLoaderInfo(IMG img, VOID* loaderInfo);

/**
 * @ingroup IMG
 * @brief Returns the image loaded after the given image, or IMG_Invalid() if it is the last image.
 *
 * Of the list of currently loaded images in memory it returns
 * the image loaded after image img, or IMG_Invalid() if img is the last image
 *
 * Skip shadow image (vdso or dynamic code)
 *
 * @param[in] img        The image object
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_Next(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the image loaded prior to the given image, or IMG_Invalid() if it is the first image.
 *
 * Of the list of currently loaded images in memory it returns
 * the image loaded prior to image img, or IMG_Invalid() if img is the first image
 *
 * @param[in] img        The image object
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_Prev(IMG img);

/**
 * @ingroup IMG
 * @brief Returns an invalid image value used to indicate no image.
 *
 * @return Used to indicate no image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_Invalid();

/**
 * @ingroup IMG
 * @brief Checks if the image is valid.
 *
 * @param[in] img        The image object to check
 *
 * @return True if img is not IMG_Invalid()
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_Valid(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the first section in the image.
 *
 * @param[in] img        The image object
 *
 * @return First section in image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC IMG_SecHead(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the last section in the image.
 *
 * @param[in] img        The image object
 *
 * @return Last section in image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC IMG_SecTail(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the first regular symbol in the image.
 *
 * @param[in] img        The image object
 *
 * @return First regular symbol in image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SYM IMG_RegsymHead(IMG img);

/**
 * @ingroup DEPRECATED
 * @brief Returns the address of first instruction executed when image is loaded.
 *
 * @param[in] img        Pin image handle
 *
 * @return Address of first instruction executed when image is loaded
 *
 * @note DEPRECATED: API returned wrong value in case of position independent code. Use IMG_EntryAddress() instead.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern PIN_DEPRECATED_API ADDRINT IMG_Entry(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the address of first instruction executed when image is loaded.
 *
 * @param[in] img        Pin image handle
 *
 * @return Address of first instruction executed when image is loaded
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_EntryAddress(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if image has the specified property.
 *
 * @param[in] img        Pin image handle
 * @param[in] property   the property to check of type @ref IMG_PROPERTY
 *
 * @return if image supports specific property in specific mode
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_HasProperty(IMG img, IMG_PROPERTY property);

/**
 * @ingroup IMG
 * @brief Returns the fully qualified actual file name of the image.
 *
 * Image names are encoded in UTF8 (a superset of ASCII),
 * this is supported for Linux (only for locales encoded in UTF8) and Windows
 *
 * @param[in] img        The image object
 *
 * @return Fully qualified actual file name of image.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern const std::string& IMG_Name(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the global pointer (GP) of the image, if a GP is used to address global data.
 *
 * @param[in] img        The image object
 *
 * @return Global pointer (GP) of image, if a GP is used to address global data
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_Gp(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the offset from the image's link-time address to its load-time address.
 *
 * @param[in] img        The image object
 *
 * @return Offset from the image's link-time address to its load-time address.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_LoadOffset(IMG img);

/**
 * @ingroup IMG
 * @brief Tells the lowest address of any code or data loaded by the image.
 *
 * @remarks
 *      If the image is split in memory, regions from other images might
 *      be mapped between its regions. In this case, the function will
 *      return the low address of the text segment.
 *      See @ref IMG_NumRegions.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return  The image's lowest address or the text segment low address if the
 *          image is split.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_LowAddress(IMG img);

/**
 * @ingroup IMG
 * @brief Tells the highest address of any code or data loaded by the image.
 *
 * This is the address of the last byte loaded by the image.
 *
 * @remarks
 *      If the image is split in memory, regions from other images might
 *      be mapped between its regions. In this case, the function will
 *      return the high address of the text segment.
 *      See @ref IMG_NumRegions.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return  The image's highest address or the text segment high address if the
 *          image is split.
 *
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_HighAddress(IMG img);

/**
 * @ingroup IMG
 * @brief Returns a pointer to the start of the raw image file.
 *
 * On Windows, the whole image has been loaded by system loader at once. IMG_StartAddress()
 * gives the pointer to the image, mapped by loader.
 * If you are working inside image-load callback - IMG_LowAddress() and IMG_StartAddress()
 * return the same value.
 *
 * On Unix, the loader maps only portions of the image file that contain
 * code and data. Additionally, Pin maps the whole image file for parsing.
 * IMG_StartAddress() returns a pointer to the memory mapped file.
 * After return form image-load callback the whole image file is being unmapped and
 * the pointer becomes invalid. The IMG_StartAddress() returns 0.
 *
 * Note, On Unix, the IMG_LowAddress() and IMG_StartAddress() return different values.
 *
 * On IMG_Open(), Pin maps the whole image into memory and the pointer is valid until IMG_Close()
 *
 * @param[in] img  The Pin image handle.
 *
 * @return  Pointer to the start of the raw image file.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_StartAddress(IMG img);

/**
 * @ingroup IMG
 * @brief Tells the size of the raw image mapped by Pin.
 *
 * Tells the size of the raw image mapped by Pin, including the size of the image's
 * symbolic information, which is not normally mapped by the application.  Use this with
 * IMG_StartAddress() to find the entire memory range of the raw image mapped by Pin.
 *
 * Note, this does \e not give the address range of the image from the application's
 * perspective.  To get that, use IMG_LowAddress() and IMG_HighAddress().
 *
 * On Linux, the file is mapped in image-load callback or after IMG_Open.
 * In other cases the IMG_SizeMapped returns 0.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return  Size (bytes) of the raw image file mapped by Pin.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern USIZE IMG_SizeMapped(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the image type.
 *
 * @param[in] img        The image object
 *
 * @return Image type
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG_TYPE IMG_Type(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if this is the main executable image.
 *
 * @param[in] img          The image object
 *
 * @return TRUE for the image Pin was applied on in the command line (i.e. first param after --)
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_IsMainExecutable(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if the image has debug information that includes the lines information.
 *
 * @param[in] img          The image object
 *
 * @return TRUE if img has debug information that includes the  lines information.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_hasLinesData(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if this is the image of the application's loader (interpreter).
 *
 * On operating systems that have the concept of loader image.
 * (i.e. another program that is resposible to load the application),
 * this function return TRUE for the image of the loader.
 * In operating system that don't have the concept of loader, this
 * function returns FALSE on all images.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return TRUE if this is the image of the application's loader (interpreter).
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_IsInterpreter(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if this is the static executable.
 *
 * @param[in] img          The image object
 *
 * @return TRUE if this is the static executable
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_IsStaticExecutable(IMG img);

/**
 * @ingroup IMG
 * @brief Checks if this is the VDSO image.
 *
 * On Linux this function return TRUE for the image of the VDSO.
 * On other operating systems return FALSE for all images.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return TRUE if this is the VDSO image.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL IMG_IsVDSO(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the number of consecutive regions of the image in memory.
 *
 * @param[in] img        The image object
 *
 * @return number of consecutive regions of the image in memory
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern UINT32 IMG_NumRegions(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the high address of the n'th region.
 *
 * @param[in] img        The image object
 * @param[in] n          The region index (starts at 0)
 *
 * @remark n starts at 0
 *
 * @return the high address of the n'th region
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_RegionHighAddress(IMG img, UINT32 n);

/**
 * @ingroup IMG
 * @brief Returns the low address of the n'th region.
 *
 * @param[in] img        The image object
 * @param[in] n          The region index (starts at 0)
 *
 * @remark n starts at 0
 *
 * @return the low address of the n'th region
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT IMG_RegionLowAddress(IMG img, UINT32 n);

/**
 * @ingroup SEC
 * @brief Returns the image that contains this section.
 *
 * @param[in] sec        The section object
 *
 * @return Image that contains this section
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG SEC_Img(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the section that follows the given section, or SEC_Invalid() if it is last.
 *
 * @param[in] sec        The section object
 *
 * @return Section that follows sec, or SEC_Invalid() is sec is last section in the image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC SEC_Next(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the previous section, or SEC_Invalid() if this is the first in the image.
 *
 * @param[in] sec        The section object
 *
 * @return Previous section of sec, or SEC_Invalid() if sec is the first in the image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC SEC_Prev(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns an invalid section value.
 *
 * @return Invalid section value
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC SEC_Invalid();

/**
 * @ingroup SEC
 * @brief Checks if the section is valid.
 *
 * @param[in] sec          The section object to check
 *
 * @return True if sec is not SEC_Invalid()
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL SEC_Valid(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the first RTN of the section, or RTN_Invalid() if no RTNs.
 *
 * @param[in] sec        The section object
 *
 * @return First RTN of sec, or RTN_Invalid() if no RTNs
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN SEC_RtnHead(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the last RTN of the section, or RTN_Invalid() if no RTNs.
 *
 * @param[in] sec        The section object
 *
 * @return Last RTN of sec, or RTN_Invalid() if no RTNs
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN SEC_RtnTail(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the section name.
 *
 * @param[in] sec        The section object
 *
 * @return Section name
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern const std::string& SEC_Name(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the section type.
 *
 * @param[in] sec        The section object
 *
 * @return Section type
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC_TYPE SEC_Type(SEC sec);

/**
 * @ingroup SEC
 * @brief Checks if section is mapped in memory.
 *
 * @param[in] sec        The section object
 *
 * @return True if section is mapped in memory, unmapped section contain data not needed at run time, like debug information
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL SEC_Mapped(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns a pointer to the raw data for the section.
 *
 * On Linux, Pin maps the whole image file for processing. The pointer returned by SEC_Data()
 * points inside the mapped file.
 * Note, SEC_Data() pointer is always between IMG_StartAddress() and IMG_StartAddress() + IMG_SizeMapped().
 * If you are analyzing image in image-load callback, please remember that the image will be unmapped
 * after the callback returns and the pointer provided by SEC_Data() becomes invalid.
 * If you are working with IMG_Open() the pointer is valid until IMG_Close().
 *
 * If section does not have raw data the function returns 0.
 *
 * @param[in] sec        The section object
 *
 * @return Return a pointer to the raw data for the section
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern const VOID* SEC_Data(SEC sec);

/**
 * @ingroup RTN
 * @brief Returns the section that contains this routine.
 *
 * @param[in] rtn        The routine object
 *
 * @return Section that contains this routine
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SEC RTN_Sec(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the routine that follows this routine, or RTN_Invalid() if it is the last.
 *
 * @param[in] rtn        The routine object
 *
 * @return Routine that follows rtn, or RTN_Invalid() if rtn is the last in the section
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_Next(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the routine that precedes this routine, or RTN_Invalid() if it is the first.
 *
 * @param[in] rtn        The routine object
 *
 * @return Routine that precedes rtn, or @ref RTN_Invalid() if rtn is the first in the section
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_Prev(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns an RTN value that indicates no valid image.
 *
 * @return RTN value that indicates no valid image
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_Invalid();

/**
 * @ingroup RTN
 * @brief Checks if the RTN is valid.
 *
 * RTN_Valid() returns FALSE in certain cases when there is no static image of the code available,
 * including dynamically generated code.
 *
 * @param[in] rtn        The routine object to check
 *
 * @return True if rtn is not RTN_Invalid().
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL RTN_Valid(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the name of the routine.
 *
 * @param[in] rtn        The routine object
 *
 * @return Name of routine
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern const std::string& RTN_Name(RTN rtn);

/**
 * @ingroup RTN
 * @brief Checks if the RTN is artificial.
 *
 * An artificial RTN is an RTN which was introduced by PIN for internal management
 * and does not really represent an actual routine in the application.
 * For example, PIN might cover code pieces that are not associated with symbols with
 * artificial RTNs in order to meet the requirement that all code must be
 * covered with RTNs.
 *
 * @param[in] rtn        The routine object
 *
 * @return TRUE if RTN is artificial.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL RTN_IsArtificial(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the SYM associated with the given routine.
 *
 * @param[in] rtn        The routine object
 *
 * @return SYM associated with the given routine
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern SYM RTN_Sym(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the method ID associated with the given routine (JIT Profiling).
 *
 * @param[in] rtn        The routine object
 *
 * @return Method ID associated with the given routine (JIT Profiling)
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux, Windows & MacOS\n
 * \b CPU:   All\n
 *
 */
extern UINT RTN_DynamicMethodId(RTN rtn);

/**
 * @ingroup RTN
 * @brief Converts an RTN to a function pointer.
 *
 * @param[in] rtn        The routine object
 *
 * @return function pointer
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern AFUNPTR RTN_Funptr(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns a unique ID for the routine.
 *
 * Pin assigns each routine a unique ID.
 * The ID is globally unique, i.e. an ID will not appear in two images. If the same routine name
 * exists in two different images (i.e. they are in different addresses), each will have a
 * different ID. If an image is unloaded and then reloaded, the routines within it will most
 * likely have different IDs than before.
 *
 * @param[in] rtn        The routine object
 *
 * @return Unique ID for the routine.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern UINT32 RTN_Id(RTN rtn);

/**
 * @ingroup BBL
 * @brief Returns the first instruction of the BBL.
 *
 * @param[in] bbl        The BBL object
 *
 * @return First instruction of bbl
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS BBL_InsHead(BBL bbl);

/**
 * @ingroup BBL
 * @brief Returns the last instruction of the BBL.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Last instruction of bbl
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS BBL_InsTail(BBL bbl);

/**
 * @ingroup BBL
 * @brief Returns the next BBL or BBL_INVALID() if this is the end of trace or rtn.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Next bbl or BBL_INVALID() if this is the end of trace or rtn
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BBL BBL_Next(BBL bbl);

/**
 * @ingroup BBL
 * @brief Returns the previous BBL or BBL_INVALID() if this is the beginning of trace or rtn.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Previous bbl or BBL_INVALID() if this is the beginning of trace or rtn
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BBL BBL_Prev(BBL bbl);

/**
 * @ingroup BBL
 * @brief Checks if the BBL is valid.
 *
 * @param[in] bbl        The BBL object to check
 *
 * @return True if bbl is not BBL_INVALID()
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL BBL_Valid(BBL bbl);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the routine that contains this instruction.
 *
 * See @ref RTN_FindByAddress for more information.
 *
 * @param[in] ins        The instruction object
 *
 * @return Routine that contains this instruction
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN INS_Rtn(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the instruction that follows this instruction.
 *
 * @param[in] ins        The instruction object
 *
 * @return Instruction that follows ins, or @ref INS_Invalid() if ins is the last in the rtn or trace
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS INS_Next(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the instruction that precedes this instruction.
 *
 * @param[in] ins        The instruction object
 *
 * @return Instruction that precedes ins, or INS_Invalid() if ins is the first in the rtn or trace
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS INS_Prev(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns an invalid instruction used in iterators.
 *
 * @return Invalid instruction used in iterators @ref INS_Prev and @ref INS_Next
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS INS_Invalid();

/**
 * @ingroup INS_INSPECTION
 * @brief Checks if the instruction is valid.
 *
 * @param[in] ins        The instruction object to check
 *
 * @return TRUE if ins is not INS_Invalid()
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL INS_Valid(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the address of the instruction.
 *
 * @param[in] ins        The instruction object
 *
 * @return Address of instruction
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT INS_Address(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the size of instruction in bytes.
 *
 * @param[in] ins        The instruction object
 *
 * @return Size of instruction in bytes
 *
 */
extern USIZE INS_Size(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the target address for direct branches or calls.
 *
 * @param[in] ins        The instruction object
 *
 * @return For direct branches or calls, the target address
 *
 * @note DEPRECATED: see @ref INS_DirectControlFlowTargetAddress() instead.
 *
 */
extern PIN_DEPRECATED_API ADDRINT INS_DirectBranchOrCallTargetAddress(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Returns the target address for direct control-flow instructions.
 *
 * Must verify that @ref INS_IsDirectControlFlow() is true before using this function.
 * Refer to @ref INS_IsControlFlow() for more details on control-flow instructions.
 *
 * @param[in] ins        The instruction object
 *
 * @return the target address for direct control-flow instructions.
 *
 */
extern ADDRINT INS_DirectControlFlowTargetAddress(INS ins);

/**
 * @ingroup INS_INSPECTION
 * @brief Gets the address of the next instruction.
 *
 * @param[in] ins        The instruction object
 *
 * @return Address of instruction that follows this one
 *
 */
extern ADDRINT INS_NextAddress(INS ins);

/**
 * @ingroup SYMBOLS
 * @brief Returns the routine that follows this symbol, or SYM_Invalid() if it is the last.
 *
 * @param[in] sym          The symbol object
 *
 * @return Routine that follows sym, or SYM_Invalid() if sym is the last in the section
 *
 */
extern SYM SYM_Next(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns the routine that precedes this symbol, or SYM_Invalid() if it is the first.
 *
 * @param[in] sym          The symbol object
 *
 * @return Routine that precedes sym, or SYM_Invalid() if sym is the first in the section
 *
 */
extern SYM SYM_Prev(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns the name of the symbol.
 *
 * @param[in] sym          The symbol object
 *
 * @return Name of symbol
 *
 */
extern const std::string& SYM_Name(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns a value used to indicate no symbol.
 *
 * @return Used to indicate no symbol
 *
 */
extern SYM SYM_Invalid();

/**
 * @ingroup SYMBOLS
 * @brief Checks if the symbol is valid.
 *
 * @param[in] sym          The symbol object to check
 *
 * @return True if sym is not SYM_Invalid()
 *
 */
extern BOOL SYM_Valid(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Checks if the symbol is a dynamic symbol.
 *
 * @param[in] sym          The symbol object
 *
 * @return True if sym is a dynamic symbol
 *
 */
extern BOOL SYM_Dynamic(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Checks if the symbol was generated by Pin.
 *
 * @param[in] sym          The symbol object
 *
 * @return True if sym is a symbol which did not appear in the image's original symbol table and was
 *             added by Pin (for example when resolving an ifunc).
 *         False if the symbol existed in the image's symbol table
 *
 */
extern BOOL SYM_GeneratedByPin(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Checks if the symbol is an IFUNC implementation symbol.
 *
 * @param[in] sym          The symbol object
 *
 * @return True if sym is an IFUNC implementation symbol
 *
 */
extern BOOL SYM_IFuncImplementation(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Checks if the symbol is an IFUNC resolver symbol.
 *
 * @param[in] sym          The symbol object
 *
 * @return True if sym is an IFUNC resolver symbol
 *
 */
extern BOOL SYM_IFuncResolver(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns the value of the symbol, usually an address relative to beginning of image.
 *
 * @param[in] sym          The symbol object
 *
 * @return Value of symbol, usually an address relative to beginning of image
 *
 */
extern ADDRINT SYM_Value(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns the section index of a symbol.
 *
 * @param[in] sym          The symbol object
 *
 * Pin keeps the symbols ordered by their address location in the image.
 * The index represents the order in which they were found when processing the 
 * different symbol table sections and debug information.
 *
 * @note There is no guarantee that the index represents the order of the symbols in the image.
 *       Also, when both symbol table and debug information are available, all that can be said
 *       is that the symbol table symbols will have lower indexes than the debug information symbols.
 * 
 *
 * @return section index of a symbol
 *
 */
extern UINT32 SYM_Index(SYM sym);

/**
 * @ingroup SYMBOLS
 * @brief Returns the address of the symbol in memory.
 *
 * @param[in] sym          The symbol object
 *
 * @return address of the symbol in memory
 *
 */
extern ADDRINT SYM_Address(SYM sym);

/*! @ingroup IMG
  Type of function to be called when an image is loaded
*/
typedef VOID (*IMAGECALLBACK)(IMG, VOID*);

/*! @ingroup IMG
   Type of function to be called before processing symbols of an image.
   If the function returns FALSE, the symbol processing is skipped for the image.
 */
typedef BOOL (*IMAGE_PRE_DEBUG_INFO_PROCESS_CALLBACK)(IMG, VOID*);

/*! @ingroup PIN_CONTROL
    List of supported modes of symbolic information delivery.
    Used in PIN_InitSymbolsAlt().
*/
enum SYMBOL_INFO_MODE
{
    NO_SYMBOLS     = 0,        ///< No symbols required
    EXPORT_SYMBOLS = (1 << 0), ///< Only symbols taken from symbol tables are provided.
                               ///< On Windows, these are the export symbols.
                               ///< On Linux, these are the symbols from .dynsym and .symtab sections.
    DEBUG_SYMBOLS = (1 << 1),  ///< Debug symbols (Currently implemented as DEBUG_AND_EXPORT_SYMBOLS)
    IFUNC_SYMBOLS = (1 << 2),  ///< IFUNC symbols (Linux only). When this flag is specified, Pin resolves
                               ///< IFUNC symbols to their actual implementations and provides
                               ///< those as symbols. This flag can be combined with EXPORT_SYMBOLS
                               ///< and/or DEBUG_SYMBOLS. Specifying only this flag has the same effect as
                               ///< NO_SYMBOLS.
    DEBUG_AND_EXPORT_SYMBOLS = (DEBUG_SYMBOLS | EXPORT_SYMBOLS), ///< Export (symbol table) symbols are provided along with
                                                                 ///< debug symbols if they are available and not explicitly
                                                                 ///< disabled. This is the default mode on both Windows & Linux.
    DEBUG_OR_EXPORT_SYMBOLS = DEBUG_AND_EXPORT_SYMBOLS /// This option is deprecated, use DEBUG_AND_EXPORT_SYMBOLS instead
};

/*! @ingroup SYMBOLS
 * Class that represents an adddress range for a symbol
 */
class SymbolAddressRange
{
  public:
    SymbolAddressRange() : base(0), size(0) {}
    SymbolAddressRange(ADDRINT sym_base, size_t sym_size) : base(sym_base), size(sym_size) {}
    SymbolAddressRange(const SymbolAddressRange& obj) : base(obj.base), size(obj.size) {}
    SymbolAddressRange& operator=(const SymbolAddressRange& obj)
    {
        if (this == &obj)
        {
            return *this;
        }
        base = obj.base;
        size = obj.size;
        return *this;
    }
    BOOL operator<(const SymbolAddressRange& range) const { return (base < range.base); }
    BOOL Contains(const ADDRINT addr) const
    {
        if (0 == size)
        {
            return addr == base;
        }
        return ((addr - base) < size);
    }

  public:
    ADDRINT base;
    size_t size;
};

/*! @ingroup SYMBOLS
 * Represents debug info for a symbol: symbol name and address range
 */
struct SymbolDebugInfo
{
    SymbolDebugInfo(const char* sym_name, ADDRINT sym_base, size_t sym_size, uint32_t sym_index, bool is_inlined)
        : name(sym_name), range(sym_base, sym_size), index(sym_index), inlined(is_inlined)
    {}

    const char* const name;   ///< Symbol name
    SymbolAddressRange range; ///< Address range of the symbol
    uint32_t index;           ///< The index of the symbol in the order it was extracted from the debug info.
    bool inlined;             ///< True if the symbol represents an inlined function from debug info

    bool operator<(const SymbolDebugInfo& info) const { return range < info.range; }
};

/**
 * @ingroup IMG
 * @brief Returns a unique ID for the image.
 *
 * If an image is unloaded, the ID is not reused for a different image.
 * If an image is unloaded and the same one is loaded back, the ID is different.
 *
 * @param[in] img          The image object
 *
 * @return Unique ID for the image.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern UINT32 IMG_Id(IMG img);

/**
 * @ingroup IMG
 * @brief Returns the pointer to the object that was passed by the application for reporting the creation of a dynamic image via the Jit Profiling API.
 *
 * The pointer is available only for dynamic images,
 * and only during the image load and routine instrumentation callbacks.
 * In all other cases, the function returns NULL.
 *
 * @param[in] img  The Pin image handle.
 *
 * @return  pointer to the object, or NULL.
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux*\n
 * \b CPU:   All\n
 *
 */
extern VOID* IMG_DynamicRawData(IMG img);

/**
 * @ingroup IMG
 * @brief Finds an image by its ID.
 *
 * @param[in] id         The image ID to search for
 *
 * @return IMG object, valid or invalid
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_FindImgById(UINT32 id);

/**
 * @ingroup IMG
 * @brief Finds an image by address.
 *
 * For each image, check if the address is within the mapped memory region of one of its
 * segments.
 *
 * @param[in] address    The address to search for
 *
 * @return IMG object, valid or invalid
 *
 * @note The pin client lock must be obtained before calling this API from outside
 * an instrumentation callback.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_FindByAddress(ADDRINT address);

/**
 * @ingroup RTN
 * @brief Adds a function used to instrument at routine granularity.
 *
 * @param[in] fun        Instrumentation function for routines
 * @param[in] val        Passed as the second argument to the instrumentation function
 *
 * @return PIN_CALLBACK A handle to a callback that can be used to further modify this callback's properties
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern PIN_CALLBACK RTN_AddInstrumentFunction(RTN_INSTRUMENT_CALLBACK fun, VOID* val);

/**
 * @ingroup IMG
 * @brief Registers a callback to catch the loading of an image.
 *
 * @param[in] fun        Instrumentation function for images, it is passed an image and v
 * @param[in] v          the value of to pass to fun when an image is loaded
 *
 * @return PIN_CALLBACK A handle to a callback that can be used to further modify this callback's properties
 *
 * @note The pin client lock must be obtained before calling this API from outside main() or instrumentation callbacks.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern PIN_CALLBACK IMG_AddInstrumentFunction(IMAGECALLBACK fun, VOID* v);

/**
 * @ingroup IMG
 * @brief Registers a callback to be used when an image is unloaded.
 *
 * This is not an instrumentation function--it doesn't make sense to instrument a function when it removed from memory.
 *
 * @param[in] fun        passed an image and v when an image is unloaded
 * @param[in] v          the value to pass to fun when an image is unloaded
 *
 * @return PIN_CALLBACK A handle to a callback that can be used to further modify this callback's properties
 *
 * @note The pin client lock must be obtained before calling this API from outside main() or instrumentation callbacks.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern PIN_CALLBACK IMG_AddUnloadFunction(IMAGECALLBACK fun, VOID* v);

/**
 * @ingroup IMG
 * @brief Registers a callback to be invoked before processing debug information for the image.
 *
 * If the callback returns FALSE, debug information processing is skipped for the image.
 * This API can be used to optimize symbol (SYM) processing when the tool is interested
 * only in symbols (SYM/RTN) from certain images.
 * In some cases, skipping debug information processing can significantly
 * reduce Pin's initialization time or image load processing time.
 *
 * By the time the callback is called, the image is already loaded and most image information is available.
 * However, RTNs are not yet created, and only symbols (SYM) from the export/symbol table are available.
 * It is recommended not to emit any instrumentation from within this callback; use it only to decide
 * whether to process debug information symbols for the image.
 *
 * @param[in] fun        passed an image and v before processing symbols from the image's debug information
 * @param[in] v          the value to pass to fun when it is called
 *
 * @note Symbols (SYM) from the export/symbol table are always processed, regardless of the return value of this callback.
 * @note Skipping debug information processing only affects RTN construction and SYM APIs. It does not affect PIN_GetSourceLocation API.
 *
 * @note The pin client lock must be obtained before calling this API from outside main() or instrumentation callbacks.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern VOID IMG_AddPreDebugInfoProcessCallback(IMAGE_PRE_DEBUG_INFO_PROCESS_CALLBACK fun, VOID* v);

/**
 * @ingroup RTN
 * @brief Returns the range of routine in bytes.
 *
 * (until the next known symbol or end of current code region).
 *
 * @param[in] rtn        The routine object
 *
 * @return range of routine in bytes
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern USIZE RTN_Range(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the size of routine in bytes.
 *
 * @param[in] rtn        The routine object
 *
 * @return size of routine in bytes
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern USIZE RTN_Size(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the resolver function that led to this implementation (ifunc).
 *
 * @param[in] rtn        The routine object
 *
 * @return The resolver function that led to this implementation (ifunc)
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_IFuncResolver(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the implementation function that this ifunc points to.
 *
 * @param[in] rtn        The routine object
 *
 * @return The implementation function that this ifunc points to
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_IFuncImplementation(RTN rtn);

/**
 * @ingroup IMG
 * @brief Allows one to open an image and browse it statically.
 *
 * There can only be one image open at a time. File names are encoded in UTF8 (a superset of ASCII).
 *
 * @note This API can only be used at a safe point, which is before calling PIN_StartProgram()(/or similar)
 *
 * @param[in] filename   The image file name.
 *
 * @return The opened image, or IMG_INVALID() if the image cannot be opened.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG IMG_Open(const std::string& filename);

/**
 * @ingroup IMG
 * @brief Closes the open image.
 *
 * @param[in] img  The IMG that was previously opened.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern VOID IMG_Close(IMG img);

/**
 * @ingroup RTN
 * @brief Returns the name of a routine containing the given address.
 *
 * If more than one name is associated with this address, the first name found is returned.
 *
 * See @ref RTN_FindByAddress for more information.
 *
 * @param[in] address    Memory address that corresponds to the RTN
 *
 * @return Name of routine, or "" if it is not found
 *
 * @note The pin client lock is obtained during the call of this API.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern std::string RTN_FindNameByAddress(ADDRINT address);

/**
 * @ingroup RTN
 * @brief Finds the routine that contains the given memory address.
 *
 * @param[in] address    Memory address that corresponds to an RTN
 *
 * @return Handle to the RTN found. If not found returns RTN_Invalid()
 *
 * @note If a valid RTN handle is returned then it means that the given address was
 * within the RTN range. To verify that the given address is the start of the
 * RTN, you can compare it with the address returned by @ref RTN_Address.
 *
 * @note In a multithreaded program, the returned RTN handle could go stale if
 * another thread unloads the shared object that contains the RTN. Use
 * PIN_LockClient() before calling this routine and PIN_UnlockClient() after
 * the last use of the returned RTN handle. Locking is automatic from an
 * instrumentation routine, so it is unnecessary (but harmless) to lock calls
 * to this function from an instrumentation routine. If you just want the
 * name, call @ref RTN_FindNameByAddress, which automatically does the locking
 * and returns a string which will not go stale if the shared library is
 * unloaded
 *
 * @note The pin client lock  must be obtained before calling this API from outside
 * an instrumentation callback.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_FindByAddress(ADDRINT address);

/**
 * @ingroup RTN
 * @brief Finds a routine in an image by name.
 *
 * This API will also go over mangled names and demangle them for comparison.
 *
 * @param[in] img        Image in which to search for RTN
 * @param[in] name       Name of the RTN to search in IMG
 *
 * @return Handle to the RTN found. If not found returns RTN_Invalid()
 *
 * @note If more than one RTN matches the name, the first one found will be returned.
 * This can happen for overloaded functions. To find the exact overload, the correct
 * mangled name should be passed.
 *
 * @note Because this function will iterate over all RTNs in the image, and will
 * demangle each name if the given name is not an exact match, it may have severe
 * performance implications. For finding several RTNs per image or for matching all overloads,
 * it is recommended that the caller iterates over the RTNs manually and decides on the
 * search criteria themselves. See @ref PIN_UndecorateSymbolName for information about
 * name demangling.
 *
 * @note This function internally uses SYM APIs. So @ref PIN_InitSymbols should be called
 * for this API to work.
 *
 * @note The pin client lock must be obtained before calling this API from outside
 * an instrumentation callback.
 *
 * @note In case this function is an Ifunc the return value will be the RTN
 * that holds the implementation of that ifunc (Notice! this RTN can
 * be on another image. If the resolver function is needed use
 * @ref RTN_IFuncResolver().
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_FindByName(IMG img, const CHAR* name);

/**
 * @ingroup RTN
 * @brief Opens the given RTN.
 *
 * This must be called before @ref RTN_InsHead() or @ref RTN_InsertCall() or @ref RTN_InsHeadOnly()
 *
 * @param[in] rtn        The routine object to open
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern VOID RTN_Open(RTN rtn);

/**
 * @ingroup RTN
 * @brief Closes the given RTN.
 *
 * This must be called before opening a new RTN.
 *
 * @param[in] rtn        The routine object to close
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern VOID RTN_Close(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the first instruction of the RTN, or INS_Invalid() if no instructions.
 *
 * You must call RTN_Open() before the first time this is called for an RTN.
 *
 * Note that Pin find the INSs of the RTN through static discovery, so Pin does \e not guarantee
 * that it will find all the INSs in the RTN. If you need completely reliable instructions, use
 * normal JIT time instrumentation, where Pin can guarantee that the instructions are correct.
 *
 * @see RTN_InsHeadOnly(), which is provided for performance purposes.
 * If a tool wishes to examine only the first INS of an RTN it should use
 * RTN_InsHeadOnly() instead of RTN_InsHead().
 *
 * @param[in] rtn        The routine object
 *
 * @return First instruction of rtn, or INS_Invalid() if no instructions.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS RTN_InsHead(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the first instruction of the RTN, or INS_Invalid() if no instructions.
 *
 * You must call RTN_Open() before the first time this is called for an RTN.
 *
 * Note that tools should use this function when they want to examine ONLY the first
 * INS of an RTN, and NO others. The INS_Next() of the INS returned by this function may
 * be INS_Invalid() even if there are more INSs in the RTN. Tools that want to examine
 * further INSs of the RTN should call the RTN_InsHead() function instead of this one.
 *
 * @param[in] rtn        The routine object
 *
 * @return First instruction of rtn, or INS_Invalid() if no instructions.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS RTN_InsHeadOnly(RTN rtn);

/**
 * @ingroup RTN
 * @brief Returns the last instruction of the RTN, or INS_Invalid() if no instructions.
 *
 * You must call RTN_Open() before the first time this is called for an RTN.
 *
 * Note that Pin finds the INSs of the RTN through static discovery, so Pin does \e not guarantee
 * that it will find all the INSs in the RTN. If you need completely reliable instructions, use
 * normal JIT time instrumentation, where Pin can guarantee that the instructions are correct.
 *
 * @param[in] rtn        The routine object
 *
 * @return Last instruction of rtn, or INS_Invalid() if no instructions
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern INS RTN_InsTail(RTN rtn);

/**
 * @ingroup RTN
 * @brief Computes the number of static INSs inside the RTN.
 *
 * @param[in] rtn        The routine object
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern UINT32 RTN_NumIns(RTN rtn);

/**
 * @ingroup RTN
 * @brief Inserts a call relative to an RTN.
 *
 * @param[in] rtn        Routine to instrument
 * @param[in] action     Use IPOINT_BEFORE to call funptr before execution, or IPOINT_AFTER for immediately before the return
 * @param[in] funptr     Analysis function to call
 * @param[in] ...        @ref IARG_TYPE. Arguments to pass to funptr
 *
 * @note IPOINT_AFTER is implemented by instrumenting each return instruction in a routine.
 *       Pin tries to find all return instructions, but success is not guaranteed
 *
 * @note Pin does not support calling this function from either the TRACE or INS InstrumentationFunction callback
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern VOID RTN_InsertCall(RTN rtn, IPOINT action, AFUNPTR funptr, ...);

/**
 * @ingroup RTN
 * @brief Returns the address in memory of the RTN.
 *
 * @param[in] rtn        The routine object
 *
 * @return Address in memory of rtn
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT RTN_Address(RTN rtn);

/**
 * @ingroup RTN
 * @brief Creates a routine object at given address.
 *
 * In some situations user can calculate address of routine, but Pin doesn't
 * see it because there is no symbol at this point.
 * RTN_CreateAt() allows user to create a routine at a given address and assign a name
 * to it. When it is done, the routine can be searched for by address or by name.
 * The information is kept in Pin as long as the containing image is in memory.
 *
 * The address should point to code (an executable section or segment). Since the
 * whole code is "covered" by routine objects, the address should fall in one
 * of the existing routines. Pin shortens the routine, which contains the given address,
 * and creates a new routine which starts at the given address and continues till
 * the next routine or the end of the code section.
 * Close any open routine before calling this interface with @ref RTN_Close().
 *
 * @param[in] address    The start address of the new routine
 * @param[in] name       The assigned name of the new routine
 * @param[in] isIFunc    True if the symbol's type which corresponds to the new routine location is
 *                       ifunc symbol.
 *
 * @return RTN object    The routine object is valid if the address fails into code
 *                       section.
 *
 * @note The pin client lock is obtained during the call of this API.
 * @note If there is another routine object which starts at the same address this
 *       function replaces its name.
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern RTN RTN_CreateAt(ADDRINT address, std::string name);

/**
 * @ingroup RTN
 * @brief Checks if the routine is dynamically created.
 *
 * A routine can be marked as dynamically created using Jit Profiling API only.
 *
 * @param[in] rtn        The routine object
 *
 * @return TRUE if the routine is dynamically created
 *
 * @par Availability:
 * \b Mode:  JIT\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL RTN_IsDynamic(RTN rtn);

/**
 * @ingroup SEC
 * @brief Returns the address in memory of the section.
 *
 * If image is loaded by system loader, the real virtual address of section will be returned.
 * If the image is mapped by IMG_Open() the address will be inside the mapped image.
 * On Unix, if the section is not loadable, 0 will be returned in the both cases.
 *
 * @param[in] sec        The section object
 *
 * @return Address in memory of sec
 *
 */
extern ADDRINT SEC_Address(SEC sec);

/**
 * @ingroup SEC
 * @brief Checks if the section is readable.
 *
 * @param[in] sec        The section object
 *
 * @return TRUE if section is readable
 *
 */
extern BOOL SEC_IsReadable(SEC sec);

/**
 * @ingroup SEC
 * @brief Checks if the section is writable.
 *
 * @param[in] sec        The section object
 *
 * @return TRUE if section is writable
 *
 */
extern BOOL SEC_IsWriteable(SEC sec);

/**
 * @ingroup SEC
 * @brief Checks if the section is executable.
 *
 * @param[in] sec        The section object
 *
 * @return TRUE if section is executable
 *
 */
extern BOOL SEC_IsExecutable(SEC sec);

/**
 * @ingroup SEC
 * @brief Returns the size of the section.
 *
 * @param[in] sec        The section object
 *
 * @return Size of section
 *
 */
extern USIZE SEC_Size(SEC sec);

/**
 * @ingroup BBL
 * @brief Checks if the BBL data structure has been instrumented or optimized since it was created.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Whether the BBL data structure has been instrumented or optimized since it was created
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern BOOL BBL_Original(BBL bbl);

/**
 * @ingroup BBL
 * @brief Returns the address of a BBL.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Address of a bbl
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern ADDRINT BBL_Address(BBL bbl);

/**
 * @ingroup BBL
 * @brief Returns the size of the BBL code in bytes.
 *
 * @param[in] bbl        The BBL object
 *
 * @return Size of bbl code, in bytes
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern USIZE BBL_Size(BBL bbl);

/**
 * @ingroup IMG
 * @brief Returns the first image loaded into memory.
 *
 * @return The first image loaded into memory
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG APP_ImgHead();

/**
 * @ingroup IMG
 * @brief Returns the last image loaded into memory.
 *
 * @return The last image loaded into memory
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Linux, Windows\n
 * \b CPU:   All\n
 *
 */
extern IMG APP_ImgTail();

/**
 * @ingroup SYMBOLS
 * @brief Undecorates symbol name.
 *
 * Provides undecoration of C++ names and decorated C names. The behavior of this function \n
 * is compiler and OS specific. \n
 *
 * The C++ mangled name is undecorated either to its full signature (UNDECORATION_COMPLETE style) \n
 * or to [scope::]name form (UNDECORATION_NAME_ONLY style). \n
 *
 * Example of undecoration of symbol generated by Microsoft compiler in Windows:\n
 *
 * @code
 * Style                   Original name        Undecorated name
 * =====================   ==================   ======================================
 * UNDECORATION_COMPLETE   ?foo@ccc@@QAEPADH@Z  public: char * __thiscall ccc::foo(int)
 * UNDECORATION_NAME_ONLY                       ccc::foo
 * @endcode
 *
 * Symbol name decorated according to Windows IA32 C calling conventions is undecorated as follows: \n
 * @code
 * _foo     ->  foo    (__cdecl    convention)
 * _foo@4   ->  foo    (__stdcall  convention)
 * @foo@12  ->  foo    (__fastcall convention)
 * @endcode
 *
 * Example of undecoration of symbol generated by GCC compiler on Linux:\n
 *
 * @code
 * Style                   Original name                      Undecorated name
 * =====================   ==================                 ======================================
 * UNDECORATION_COMPLETE   _ZN1A7method1ERKSt6vectorIiSaIiEE  A::method1(std::vector<int, std::allocator<int> > const&)
 * UNDECORATION_NAME_ONLY                                     A::method1
 * @endcode
 *
 * Undecoration of macOS* symbols is done similarly to Linux (Remove the leading '_' and undecorate like Linux)
 *
 * You should be careful if using this function, since some of the undecorated names it generates for
 * symbols generated by the compiler may not be valid C++ symbol names. For example on Linux demangling
 * can give names like <tt>construction vtable for std::istream-in-std::iostream</tt>, or
 * <tt>non-virtual thunk to std::strstream::~strstream()</tt>, which are not valid C++ names.
 *
 * @param[in]   symbolName  Decorated name \n
 * @param[in]   style       Undecoration style, relevant only to C++ undecoration \n
 *                          Values: \n
 *                          UNDECORATION_COMPLETE  undecorate to full signature \n
 *                          UNDECORATION_NAME_ONLY undecorate to [scope::]name \n
 *
 * @return      string containing undecorated symbol name. \n
 *              If undecoration fails or not supported, the function returns the unmodified original name. \n
 *
 * @par Availability:
 * \b Mode:  JIT & Probe\n
 * \b O/S:   Windows, Linux\n
 * \b CPU:   All\n
 *
 */
extern std::string PIN_UndecorateSymbolName(const std::string& symbolName, UNDECORATION style);

#endif // PIN_G_IMAGE_PH
