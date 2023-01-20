##########################################################################
# cmake-avr toolchain
#
# The toolchain requires some variables set. Variables that has a default
# value, may be not set, if the user uses the defaults.
# 
# AVR_MCU (default: atmega8)
#   the type of AVR the application is built for
# AVR_L_FUSE
#   the LOW fuse value for the MCU used
# AVR_H_FUSE
#   the HIGH fuse value for the MCU used
#     NOTE: if the fuses are not set, 
#           target `set_fuses` will be unavailable.
# AVR_UPLOADTOOL (default: avrdude)
#     the application used to upload to the MCU
# AVR_UPLOADTOOL_PORT (default: usb)
#     the port used for the upload tool
# AVR_PROGRAMMER (default: avrispmkII)
#     the programmer hardware used
# AVR_MCU_SPEED 
#     the frequency with which the MCU will work.
#     used only for the compiler definition F_CPU
# AVR_BAUD
#     the baud rate.
#     used only for the compiler definition BAUD
# AVR_COMPILE_OPTIONS (default value see below)
#     default value: -fpack-struct -fshort-enums -Wall -Wpedantic
#                    -pedantic -funsigned-char -funsigned-bitfields
#                    -ffunction-sections -fdata-sections
##########################################################################

# cmake_minimum_required(VERSION 3.0.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# avr-gcc: error: unrecognized command line option ‘-rdynamic’
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")

##########################################################################
# executables in use
##########################################################################
find_program(AVR_CC avr-gcc REQUIRED)
find_program(AVR_CXX avr-g++ REQUIRED)
find_program(AVR_OBJCOPY avr-objcopy REQUIRED)
find_program(AVR_SIZE_TOOL avr-size REQUIRED)
find_program(AVR_OBJDUMP avr-objdump REQUIRED)
find_program(AVR_STRIP avr-strip REQUIRED)

##########################################################################
# toolchain starts with defining mandatory variables
##########################################################################
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_C_COMPILER ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# Identification
set(AVR_GCC_TOOLCHAIN TRUE)

##########################################################################
# set build type, set compiler options for build types
##########################################################################
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif(NOT CMAKE_BUILD_TYPE)

if(CMAKE_BUILD_TYPE MATCHES Release OR CMAKE_BUILD_TYPE MATCHES MinSizeRel)
    set(AVR_BUILD_FLAGS "-Os")
    set(CMAKE_C_FLAGS_RELEASE ${AVR_BUILD_FLAGS})
    set(CMAKE_CXX_FLAGS_RELEASE ${AVR_BUILD_FLAGS})
endif()

if(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(AVR_BUILD_FLAGS "-Os -save-temps -g -gdwarf-3 -gstrict-dwarf")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO ${AVR_BUILD_FLAGS})
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO ${AVR_BUILD_FLAGS})
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(AVR_BUILD_FLAGS "-O0 -save-temps -g -gdwarf-3 -gstrict-dwarf")
    set(CMAKE_C_FLAGS_DEBUG ${AVR_BUILD_FLAGS})
    set(CMAKE_CXX_FLAGS_DEBUG ${AVR_BUILD_FLAGS})
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

##########################################################################
# some necessary tools and variables for AVR builds, which may not
# defined yet
# - AVR_UPLOADTOOL
# - AVR_UPLOADTOOL_PORT
# - AVR_PROGRAMMER
# - AVR_MCU
# - AVR_SIZE_ARGS
##########################################################################

# default upload tool
if(NOT AVR_UPLOADTOOL)
    set(AVR_UPLOADTOOL avrdude
        CACHE STRING "Set default upload tool: avrdude"
    )
    find_program(AVR_UPLOADTOOL avrdude REQUIRED)
endif(NOT AVR_UPLOADTOOL)

# default upload tool port
if(NOT AVR_UPLOADTOOL_PORT)
    set(AVR_UPLOADTOOL_PORT usb
        CACHE STRING "Set default upload tool port: usb"
    )
endif(NOT AVR_UPLOADTOOL_PORT)

# default programmer (hardware)
if(NOT AVR_PROGRAMMER)
    set(AVR_PROGRAMMER avrispmkII
        CACHE STRING "Set default programmer hardware model: avrispmkII"
    )
endif(NOT AVR_PROGRAMMER)

# default MCU (chip)
if(NOT AVR_MCU)
    set(AVR_MCU atmega8 CACHE STRING "Set default MCU: atmega8")
endif(NOT AVR_MCU)

#default avr-size args
if(NOT AVR_SIZE_ARGS)
    set(AVR_SIZE_ARGS -C)
endif()
set(AVR_SIZE_ARGS ${AVR_SIZE_ARGS} --mcu=${AVR_MCU})

##########################################################################
# status messages for generating
##########################################################################
message(STATUS "Set CMAKE_FIND_ROOT_PATH to ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "Set CMAKE_SYSTEM_INCLUDE_PATH to ${CMAKE_SYSTEM_INCLUDE_PATH}")
message(STATUS "Set CMAKE_SYSTEM_LIBRARY_PATH to ${CMAKE_SYSTEM_LIBRARY_PATH}")

##########################################################################
# status messages
##########################################################################
message(STATUS "Uploadtool is: ${AVR_UPLOADTOOL}")
message(STATUS "Programmer is: ${AVR_PROGRAMMER}")
message(STATUS "Upload port is: ${AVR_UPLOADTOOL_PORT}")

if(AVR_UPLOADTOOL_OPTIONS)
    message(STATUS "Uploadtool options are: ${AVR_UPLOADTOOL_OPTIONS}")
endif()

message(STATUS "MCU is set to: ${AVR_MCU}")

if(AVR_H_FUSE AND AVR_L_FUSE)
    message(STATUS "H_FUSE is set to: ${AVR_H_FUSE}")
    message(STATUS "L_FUSE is set to: ${AVR_L_FUSE}")
endif()

##########################################################################
# add definitions
##########################################################################

set(AVR_DEF_BAUD "-DBAUD=${AVR_BAUD}")

if(NOT AVR_BAUD)
    set(DEF_BAUD "")
endif()

if(NOT AVR_MCU_SPEED)
    message(FATAL_ERROR "AVR_MCU_SPEED not specified!")
endif()

set(AVR_DEF_CPU_FRQ "-DF_CPU=${AVR_MCU_SPEED}")

add_definitions(
    ${AVR_DEF_CPU_FRQ}
    ${AVR_DEF_BAUD}
)

##########################################################################
# add_compile_options
##########################################################################

if(NOT AVR_COMPILE_OPTIONS)
    set(AVR_COMPILE_OPTIONS)
endif()
set(AVR_COMPILE_OPTIONS 
    -fpack-struct
    -fshort-enums
    -Wall
    -Wpedantic
    -pedantic
    -funsigned-char
    -funsigned-bitfields
    -ffunction-sections
    -fdata-sections
    ${AVR_COMPILE_OPTIONS}
)

add_compile_options( ${AVR_COMPILE_OPTIONS} )

##########################################################################
# user commands that does not depend on a target
##########################################################################

# get status
add_custom_target(get_status
    ${AVR_UPLOADTOOL}
    -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
    -n -v
    COMMENT "Get status from ${AVR_MCU}"
    VERBATIM
    USES_TERMINAL
)

# get fuses
add_custom_target(get_fuses
    ${AVR_UPLOADTOOL}
    -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
    -n
    -U lfuse:r:-:b
    -U hfuse:r:-:b
    COMMENT "Get fuses from ${AVR_MCU}"
    VERBATIM
    USES_TERMINAL
)

# set fuses
if (AVR_H_FUSE AND AVR_L_FUSE)
    add_custom_target(set_fuses
        ${AVR_UPLOADTOOL}
        -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
        -U lfuse:w:${AVR_L_FUSE}:m
        -U hfuse:w:${AVR_H_FUSE}:m
        COMMENT "Setup: High Fuse: ${AVR_H_FUSE} Low Fuse: ${AVR_L_FUSE}"
        VERBATIM
        USES_TERMINAL
    )
else()
    message(STATUS 
        "AVR Fuses not defined; target 'set_fuses' is not available")
endif()

# get oscillator calibration
add_custom_target(get_calibration
    ${AVR_UPLOADTOOL}
    -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
    -U calibration:r:${AVR_MCU}_calib.tmp:r
    COMMENT
        "Write calibration status of internal oscillator
to ${AVR_MCU}_calib.tmp."
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# set oscillator calibration
add_custom_target(set_calibration
    ${AVR_UPLOADTOOL}
    -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
    -U calibration:w:${AVR_MCU}_calib.hex
    COMMENT
        "Program calibration status of internal oscillator
from ${AVR_MCU}_calib.hex."
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

##########################################################################
# avr_add_executable
# - IN_VAR: AVR_TARGET
#
# Creates targets and dependencies for AVR toolchain, building an executable.
# Calls add_executable with AVR_TARGET.
##########################################################################
function(avr_add_executable AVR_TARGET)

    if(NOT ARGN)
        message(FATAL_ERROR "No source files given for ${AVR_TARGET}")
    endif()

    set(FILENAME "${AVR_TARGET}-${AVR_MCU}")
    set(ELF_FILE "${FILENAME}.elf")
    set(HEX_FILE "${FILENAME}.hex")
    set(EEP_FILE "${FILENAME}.eep")
    set(MAP_FILE "${FILENAME}.map")
    set(LST_FILE "${FILENAME}.lst")

    add_executable(${AVR_TARGET} EXCLUDE_FROM_ALL ${ARGN})

    set_target_properties(${AVR_TARGET}
        PROPERTIES
        OUTPUT_NAME ${ELF_FILE}
        COMPILE_FLAGS "-mmcu=${AVR_MCU}"
        LINK_FLAGS
        "-mmcu=${AVR_MCU} -Wl,--gc-sections -mrelax"
    )

##########################################################################
# main targets that provides output
##########################################################################

    # strip
    add_custom_command(
        OUTPUT ${ELF_FILE}
        COMMAND ${AVR_STRIP} ${ELF_FILE}
        COMMAND ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${ELF_FILE}
        DEPENDS ${AVR_TARGET}
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

    # create hex file
    add_custom_command(
        OUTPUT ${HEX_FILE}
        COMMAND ${AVR_OBJCOPY} -R .eeprom -O ihex ${ELF_FILE} ${HEX_FILE}
        DEPENDS ${ELF_FILE}
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

    # eeprom
    add_custom_command(
        OUTPUT ${EEP_FILE}
        COMMAND ${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
        --change-section-lma .eeprom=0 -O ihex ${ELF_FILE} ${EEP_FILE}
        DEPENDS ${ELF_FILE}
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

    add_custom_target(
        ${AVR_TARGET}-${AVR_MCU}
        ALL
        DEPENDS ${ELF_FILE} ${HEX_FILE} ${EEP_FILE}
        VERBATIM
        COMMENT "Build ${ELF_FILE} ${HEX_FILE} ${EEP_FILE}"
    )

##########################################################################
# user commands
##########################################################################

    set(
        UPLOADTOOL_OPTS
        -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT}
    )

    # upload - with avrdude
    add_custom_target(upload_${AVR_TARGET}
        ${AVR_UPLOADTOOL} ${UPLOADTOOL_OPTS}
        ${AVR_UPLOADTOOL_OPTIONS}
        -U flash:w:${HEX_FILE}
        DEPENDS ${HEX_FILE}
        COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

    # upload eeprom only - with avrdude
    # see also bug http://savannah.nongnu.org/bugs/?40142
    add_custom_target(upload_eeprom_${AVR_TARGET}
        ${AVR_UPLOADTOOL} ${UPLOADTOOL_OPTS}
        ${AVR_UPLOADTOOL_OPTIONS}
        -U eeprom:w:${EEP_FILE}
        DEPENDS ${EEP_FILE}
        COMMENT "Uploading ${EEP_FILE} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

    # disassemble
    add_custom_target(disassemble_${AVR_TARGET}
        ${AVR_OBJDUMP}
        -h
        -S ${ELF_FILE} > ${LST_FILE}
        DEPENDS ${ELF_FILE}
        COMMENT "Disassemble ${ELF_FILE} >>> ${LST_FILE}"
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        VERBATIM
        USES_TERMINAL
    )

endfunction()

##########################################################################
# avr_add_library
# - IN_VAR: AVR_LIB_TARGET
#
# Calls add_library and sets target properties:
#   COMPILE_FLAGS "-mmcu=${AVR_MCU}"
#   OUTPUT_NAME ${AVR_LIB_TARGET}-${AVR_MCU}
##########################################################################
function(avr_add_library AVR_LIB_TARGET)
    if(NOT ARGN)
        message(FATAL_ERROR "No source files given for ${AVR_LIB_TARGET}")
    endif()

    add_library(${AVR_LIB_TARGET} STATIC ${ARGN})

    set(FILENAME ${AVR_LIB_TARGET}-${AVR_MCU})
    set(${AVR_LIB_TARGET}_LIB_TARGET ${FILENAME} PARENT_SCOPE)

    set_target_properties(
        ${AVR_LIB_TARGET}
        PROPERTIES
            COMPILE_FLAGS "-mmcu=${AVR_MCU}"
            OUTPUT_NAME "${FILENAME}"
    )

endfunction()
