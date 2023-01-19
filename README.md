# cmake-avr

## Supported system

- Linux

It is not tested on Windows and Mac OS.

## Features

- easy to use: install and go
- disassemble hex file `disassemble`
- get fuse `get_fuse`
- get status `get_status`
- get oscillator calibration `get_calibration`
- set oscillator calibration `set_calibration`
- set fuse `set_fuse`
- upload hex `upload`
- upload eeprom `upload_eeprom`
    
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

sudo cmake --build build/ --target <target>
# or: cd build/; sudo make <target>
```

Main targets listed in Features section. Type `make help` or `cmake --build 
build --target help` for a list of all targets.

## CMake integration

```cmake
cmake_minimum_required(VERSION 3.0.0)

project(my-avr-project)

# CMAKE_BUILD_TYPE must be specified before avr-gcc is included
set(CMAKE_BUILD_TYPE Release)

find_package(avr-gcc REQUIRED)

set(AVR_MCU_SPEED 8000000)
set(AVR_BAUD 9600) 
set(AVR_MCU atmega8) # default value
set(AVR_H_FUSE 0xd9)
set(AVR_L_FUSE 0xc4)

# this information used by uploader
set(AVR_UPLOADTOOL avrdude)             # default value
set(AVR_PROGRAMMER avrispmkII)          # default value
set(AVR_UPLOADTOOL_PORT usb)            # default

set(AVR_UPLOADTOOL_OPTIONS "") # you can pass additional options

set(SOURCES main.c)
avr_add_executable(cmake_avr ${SOURCES})
```

#### LICENSE

cmake-avr is licensed under the [MIT License (MIT)](./LICENSE.md)
