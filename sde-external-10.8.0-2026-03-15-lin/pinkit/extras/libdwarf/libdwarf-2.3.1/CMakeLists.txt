#
# Copyright (C) 2025-2025 Intel Corporation.
# SPDX-License-Identifier: MIT
#


cmake_minimum_required(VERSION 3.19)

project(libdwarf C CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include_directories( ${CMAKE_BINARY_DIR} )

if(NOT DEFINED PIN_ROOT)
    message(FATAL_ERROR "PIN_ROOT is not defined")
endif()

set(CMAKE_C_COMPILER ${PIN_ROOT}/${ARCH}/pinrt/bin/pin-gcc)
# PIN_INC
# PIN_DEFS
list(APPEND PIN_DEFS -D_POSIX_C_SOURCE=200809L)
set(PIN_CFLAGS -pipe -std=c99 -fno-builtin -frounding-math -fno-stack-protector)
set(PIN_CRT_LIBS pincrt)


# set target folder on IDE
macro(set_folder target folder)
  set_target_properties(${target} PROPERTIES FOLDER ${folder})
endmacro()

# set source groups on IDE
macro(set_source_group list_name group_name)
    set(${list_name} ${ARGN})
    source_group(${group_name} FILES ${ARGN})
endmacro()

# view folders on supported IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
enable_testing()

# always include project's folder to includes
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)

### begin what was configure.cmake
# cmake macros
include(TestBigEndian)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckSymbolExists)
### Version also appears in configure.ac
set(VERSION 2.3.1)
set(PACKAGE_VERSION "\"${VERSION}\"") 
set(PACKAGE_NAME "libdwarf" )
set(PACKAGE_STRING "\"${PACKAGE_NAME} ${VERSION}\"")
string(REGEX REPLACE "[\"]" "" tarname1 "${PACKAGE_STRING}" )
string(REGEX REPLACE "[^a-zA-Z0-9_]" "-" tarname "${tarname1}" )
set(PACKAGE_TARNAME "\"${tarname}\"" )

test_big_endian(isBigEndian)
if (${isBigEndian})
  set ( WORDS_BIGENDIAN 1 )
endif()

set(HAVE_SYS_TYPES_H 1) 
set(HAVE_SYS_STAT_H 1)
set(HAVE_INTTYPES_H 1)
set(HAVE_MEMORY_H 1)
set(HAVE_STRINGS_H 1)
set(HAVE_STDINT_H 1)
set(HAVE_UNISTD_H 1)
set(HAVE_ELF_H 1)
set(HAVE_FCNTL_H 1)

set(HAVE_INTPTR_T 1)
set(HAVE_UINTPTR_T 1)


#  It's not really setting the location of libelfheader, 
#  it is really #  either elf.h, or if that is missing 
#  it is assuming  elf.h data is in the supplied libelf.

if(HAVE_ELF_H)
    set(HAVE_LOCATION_OF_LIBELFHEADER "<elf.h>")
endif()

check_c_source_runs("
  static unsigned foo( unsigned x, 
      __attribute__ ((unused)) int y)
  {  
      unsigned x2 = x + 1;
      return x2;
  } 
  
  int main(void) {
      unsigned y = 0;
      y = foo(12,y);
      return 0;
  }"    HAVE_UNUSED_ATTRIBUTE)
message(STATUS "Checking compiler supports __attribute__ unused... ${HAVE_UNUSED_ATTRIBUTE}")


message(STATUS "CMAKE_SIZEOF_VOID_P ... " ${CMAKE_SIZEOF_VOID_P} )

# libdwarf  
option(BUILD_NON_SHARED "build archive library libdwarf[p].a" TRUE)
option(BUILD_SHARED 
    "build shared library libdwarf[p].so and use it" FALSE)

#  This adds compiler option -Wall (gcc compiler warnings)
option(WALL "Add -Wall" FALSE)

#  DW_FWALLXX are gnu C++ options.
if (WALL)
  set(DW_FWALLXX -Wall -Wextra -Wno-unused-private-field -Wpointer-arith -Wmissing-declarations -Wcomment -Wformat -Wpedantic -Wuninitialized -Wshadow -Wno-long-long -Werror)
  set(DW_FWALL ${DW_FWALLXX} -Wpointer-arith -Wmissing-declarations -Wmissing-prototypes -Wdeclaration-after-statement -Wextra -Wcomment -Wformat -Wpedantic -Wuninitialized -Wno-long-long -Wshadow -Werror )
  message(STATUS "Compiler warning options... YES ${DW_FWALL}")
else()
  unset(DW_FWALL )
  message(STATUS "Compiler warning options... NO")
endif()

### end what was configure.cmake

configure_file(cmake/config.h.in config.h)

if(BUILD_NON_SHARED)
	set(DWARF_TARGETS dwarf-static)
	set(DWARF_TYPES STATIC)
	set(dwarf-target dwarf-static)
endif()
if(BUILD_SHARED)
	list(APPEND DWARF_TARGETS dwarf-shared)
	list(APPEND DWARF_TYPES SHARED)
	set(dwarf-target dwarf-shared)
endif()

add_subdirectory(src/lib/libdwarf)


message(STATUS "Install prefix ... ${CMAKE_INSTALL_PREFIX}" )
# installation of libdwarf[p] has to be in
# src/lib/libdwarf[p]/CMakeLists.txt
# so that it works properly for cmake before cmake 3.13.
