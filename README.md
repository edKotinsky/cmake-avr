# cmake-avr

## Supported system

- Linux
- Windows - maybe
- OS X

## Features

- build only hex file
- build only eeprom file
- build hex and eeprom files
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
git clone https://github.com/e154/cmake-avr.git /path/to/clone   
```

## Usage

```bash
cd cmake-avr
cmake -S . -B build/
cmake --build build/
```

#### LICENSE

cmake-avr is licensed under the [MIT License (MIT)](./LICENSE.md)
