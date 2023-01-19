cmake_minimum_required(VERSION 3.0.0)

project(cmake-avr)

set(MCU_SPEED "8000000")
set(AVR_MCU "atmega8")
set(AVR_H_FUSE 0xd9)
set(AVR_L_FUSE 0xc4)

set(AVR_UPLOADTOOL avrdude)
set(AVR_PROGRAMMER stk500v2)
set(AVR_UPLOADTOOL_PORT /dev/ttyUSB0)

include(../avr-gcc.cmake)

set(CMAKE_BUILD_TYPE Release)
set(SOURCES main.c)

avr_add_executable(cmake_avr ${SOURCES})

add_compile_options(
    -fpack-struct
    -fshort-enums
    -Wall
    -Wpedantic
    -funsigned-char
    -funsigned-bitfields
    -ffunction-sections
    -fdata-sections
    -mmcu=${AVR_MCU}
)

add_definitions( -DF_CPU=${MCU_SPEED} )
