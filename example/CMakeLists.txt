cmake_minimum_required(VERSION 3.0.0)

project(cmake-avr)

# CMAKE_BUILD_TYPE must be specified before avr-gcc is included
set(CMAKE_BUILD_TYPE Release)

set(AVR_MCU_SPEED "8000000UL")
set(AVR_BAUD 9600) 
set(AVR_MCU "atmega8") # default value
set(AVR_H_FUSE 0xd9)
set(AVR_L_FUSE 0xc4)

# this information used by uploader
set(AVR_UPLOADTOOL avrdude)     # default value
set(AVR_PROGRAMMER avrispmkII)  # default value
set(AVR_UPLOADTOOL_PORT /dev/ttyUSB0) # default: usb

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/scripts)
include(avr-gcc)
# after installation you can just call find_package
# find_package(avr-gcc REQUIRED)

set(SOURCES main.c)
avr_add_executable(cmake_avr ${SOURCES})
