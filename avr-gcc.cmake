cmake_minimum_required(VERSION 3.0.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

##########################################################################
# status messages
##########################################################################
message(STATUS "Current uploadtool is: ${AVR_UPLOADTOOL}")
message(STATUS "Current programmer is: ${AVR_PROGRAMMER}")
message(STATUS "Current upload port is: ${AVR_UPLOADTOOL_PORT}")
message(STATUS "Current uploadtool options are: ${AVR_UPLOADTOOL_OPTIONS}")
message(STATUS "Current MCU is set to: ${AVR_MCU}")
message(STATUS "Current H_FUSE is set to: ${AVR_H_FUSE}")
message(STATUS "Current L_FUSE is set to: ${AVR_L_FUSE}")

##########################################################################
# executables in use
##########################################################################
find_program(AVR_CC avr-gcc)
find_program(AVR_CXX avr-g++)
find_program(AVR_OBJCOPY avr-objcopy)
find_program(AVR_SIZE_TOOL avr-size)
find_program(AVR_OBJDUMP avr-objdump)

##########################################################################
# toolchain starts with defining mandatory variables
##########################################################################
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_C_COMPILER ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})

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
    find_program(AVR_UPLOADTOOL avrdude)
endif(NOT AVR_UPLOADTOOL)

# default upload tool port
if(NOT AVR_UPLOADTOOL_PORT)
    set(AVR_UPLOADTOOL_PORT usb
        CACHE STRING "Set default upload tool port: usb"
    )
endif(NOT AVR_UPLOADTOOL_PORT)

# default programmer (hardware)
if(NOT AVR_PROGRAMMER)
    message(FATAL_ERROR "AVR_PROGRAMMER is not specified!")
endif(NOT AVR_PROGRAMMER)

# default MCU (chip)
if(NOT AVR_MCU)
    message(FATAL_ERROR "AVR_MCU is not specified!")
endif(NOT AVR_MCU)

#default avr-size args
if(NOT AVR_SIZE_ARGS)
    set(AVR_SIZE_ARGS -C --mcu=${AVR_MCU})
endif(NOT AVR_SIZE_ARGS)

##########################################################################
# status messages for generating
##########################################################################
message(STATUS "Set CMAKE_FIND_ROOT_PATH to ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "Set CMAKE_SYSTEM_INCLUDE_PATH to ${CMAKE_SYSTEM_INCLUDE_PATH}")
message(STATUS "Set CMAKE_SYSTEM_LIBRARY_PATH to ${CMAKE_SYSTEM_LIBRARY_PATH}")

##########################################################################
# set build type, set compiler options for build types
##########################################################################
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

if(CMAKE_BUILD_TYPE MATCHES Release)
    add_compile_options( -Os )
endif()

if(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    add_compile_options( -Os -save-temps -g -gdwarf-3 -gstrict-dwarf )
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options( -O0 -save-temps -g -gdwarf-3 -gstrict-dwarf )
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

##########################################################################
# avr-gcc: error: unrecognized command line option ‘-rdynamic’
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")

##########################################################################
#
##########################################################################
add_executable(${EXECNAME} ${SOURCES})

set(ELF_FILE "${EXECNAME}_${AVR_MCU}.elf")
set(HEX_FILE "${EXECNAME}_${AVR_MCU}.hex")
set(EEP_FILE "${EXECNAME}_${AVR_MCU}.eep")

set_target_properties(${EXECNAME} PROPERTIES OUTPUT_NAME ${ELF_FILE})

# strip
add_custom_target(strip ALL
    COMMAND avr-strip ${ELF_FILE}
    COMMAND ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${ELF_FILE}
    DEPENDS ${EXECNAME}
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# create hex file
add_custom_target(hex ALL
    ${AVR_OBJCOPY} -R .eeprom -O ihex ${ELF_FILE} ${HEX_FILE}
    DEPENDS strip
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# eeprom
add_custom_target(eeprom ALL
    ${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
    --change-section-lma .eeprom=0 -O ihex ${ELF_FILE} ${EEP_FILE}
    DEPENDS strip
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# upload - with avrdude
add_custom_target(upload
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    ${AVR_UPLOADTOOL_OPTIONS} 
    -U flash:w:${HEX_FILE} 
    -P ${AVR_UPLOADTOOL_PORT}
    DEPENDS hex
    COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# upload eeprom only - with avrdude
# see also bug http://savannah.nongnu.org/bugs/?40142
add_custom_target(upload_eeprom
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    ${AVR_UPLOADTOOL_OPTIONS} 
    -U eeprom:w:${EEP_FILE} 
    -P ${AVR_UPLOADTOOL_PORT}
    DEPENDS eeprom
    COMMENT "Uploading ${EEP_FILE} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# get status
add_custom_target(get_status
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    -P ${AVR_UPLOADTOOL_PORT} 
    -n 
    -v
    COMMENT "Get status from ${AVR_MCU}"
)

# get fuses
add_custom_target(get_fuses
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    -P ${AVR_UPLOADTOOL_PORT} 
    -n
    -U lfuse:r:-:b
    -U hfuse:r:-:b
    COMMENT "Get fuses from ${AVR_MCU}"
)

# set fuses
add_custom_target(set_fuses
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    -P ${AVR_UPLOADTOOL_PORT}
    -U lfuse:w:${AVR_L_FUSE}:m
    -U hfuse:w:${AVR_H_FUSE}:m
    COMMENT "Setup: High Fuse: ${AVR_H_FUSE} Low Fuse: ${AVR_L_FUSE}"
)

# get oscillator calibration
add_custom_target(get_calibration
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    -P ${AVR_UPLOADTOOL_PORT}
    -U calibration:r:${AVR_MCU}_calib.tmp:r
    COMMENT "Write calibration status of internal oscillator to ${AVR_MCU}_calib.tmp."
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# set oscillator calibration
add_custom_target(set_calibration
    ${AVR_UPLOADTOOL} 
    -p ${AVR_MCU} 
    -c ${AVR_PROGRAMMER} 
    -P ${AVR_UPLOADTOOL_PORT}
    -U calibration:w:${AVR_MCU}_calib.hex
    COMMENT "Program calibration status of internal oscillator from ${AVR_MCU}_calib.hex."
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)

# disassemble
add_custom_target(disassemble
    ${AVR_OBJDUMP} 
    -h 
    -S ${ELF_FILE} > "disasm_${AVR_MCU}.lst"
    DEPENDS strip
    COMMENT "Disassemble ${ELF_FILE} >>> disasm_${AVR_MCU}.lst"
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM
    USES_TERMINAL
)
