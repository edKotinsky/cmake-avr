# cmake-avr

## Supported system

- Linux

It is not tested on Windows and Mac OS.

## Features

- easy to use: install and go
- disassemble hex file
- get fuse
- get status
- get oscillator calibration
- set oscillator calibration
- set fuse
- upload hex
- upload eeprom
    
## Install

```sh
git clone https://github.com/e154/cmake-avr.git
cd cmake-avr
cmake -S . -B build/
# cmake -S . -B build/ -D BUILD_EXAMPLE=ON
sudo cmake --build build/ --target install
```

## Usage

```sh
cmake -S . -B build/
cmake --build build/
# or cd build/; make

cmake --build build/ --target <target>
# or: cd build/; make <target>
```

Type `make help` or `cmake --build build --target help` for a list of all 
targets.

On Linux systems targets, which interacts with usb port, requires `sudo`.

## CMake integration

```cmake
cmake_minimum_required(VERSION 3.0.0)

project(my-avr-project)

set(CMAKE_BUILD_TYPE Release)

set(AVR_MCU_SPEED 8000000UL)
set(AVR_MCU atmega8) # default value
set(AVR_H_FUSE 0xd9)
set(AVR_L_FUSE 0xc4)

# this information used by uploader
set(AVR_UPLOADTOOL avrdude)             # default value
set(AVR_PROGRAMMER avrispmkII)          # default value
set(AVR_UPLOADTOOL_PORT usb)            # default

set(AVR_UPLOADTOOL_OPTIONS "") # you can pass additional options
set(AVR_COMPILE_OPTIONS "") # additional compile options

find_package(avr-gcc REQUIRED)

set(SOURCES main.c)
avr_add_executable(cmake_avr ${SOURCES})
```

## LICENSE

cmake-avr is licensed under the [MIT License (MIT)](./LICENSE.md)
