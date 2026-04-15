#
# Copyright (C) 2025-2025 Intel Corporation.
# SPDX-License-Identifier: MIT
#


file(GLOB SOURCES src/lib/libdwarf/*.c )
file(GLOB HEADERS src/lib/libdwarf/*.h )

set_source_group(CONFIGURATION_FILES "Configuration Files" 
    ${PROJECT_SOURCE_DIR}/cmake/config.h.in 
    ${PROJECT_BINARY_DIR}/config.h)
	
list(LENGTH DWARF_TARGETS targetCount)
math(EXPR targetCount "${targetCount} - 1")

foreach(i RANGE ${targetCount})
	list(GET DWARF_TARGETS ${i} target)
	list(GET DWARF_TYPES ${i} type)
	add_library(${target} ${type} ${SOURCES} ${HEADERS}
            ${GENNAMES_OUTPUT} ${CONFIGURATION_FILES})

	set_folder(${target} src/lib/libdwarf)
	target_include_directories(${target} PUBLIC 
            ${PIN_INC}
            ${LIBELF_INCLUDE_DIRS})
    target_compile_options(${target} PRIVATE -DLIBDWARF_BUILD
            ${PIN_DEFS}
            ${DW_FWALL}
            ${PIN_CFLAGS})

	target_link_libraries(${target} PUBLIC ${LIBELF_LIBRARIES})
	target_link_libraries(${target} PUBLIC ${PIN_CRT_LIBS})
	
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE C)
	set_target_properties(${target} PROPERTIES OUTPUT_NAME dwarf)

    install(TARGETS ${target} DESTINATION ${PIN_ROOT}/${ARCH}/lib)
endforeach()