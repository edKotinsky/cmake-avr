cmake_minimum_required(VERSION 3.0.0)

project(cmake-avr)

# these definitions must be before avr-gcc is included
set(MCU_SPEED "8000000")
set(AVR_MCU "atmega8")
set(AVR_H_FUSE 0xd9)
set(AVR_L_FUSE 0xc4)

set(AVR_UPLOADTOOL avrdude)
set(AVR_PROGRAMMER stk500v2)
set(AVR_UPLOADTOOL_PORT /dev/ttyUSB0)

set(CMAKE_BUILD_TYPE Release)

set(CMAKE_MODULE_PATH ..)
include(avr-gcc)
# after installation you can just call find_package
# find_package(avr-gcc REQUIRED)

set(SOURCES main.c)
avr_add_executable(cmake_avr ${SOURCES})

message(STATUS "current c compiler is ${CMAKE_C_COMPILER}")

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
