# PicoFabric Examples :lemon: # 
[![Install](https://img.shields.io/badge/VSCode-Extension-f3cd5a?longCache=true&style=flat-rounded)](https://github.com/picolemon/picofabric-ide)
[![datasheet (pdf)](https://img.shields.io/badge/Data%20Sheet-PDF-f3cd5a?longCache=true&style=flat-rounded)](https://github.com/picolemon/picofabric-hardware/blob/main/doc/datasheet.pdf)
[![sch (pdf)](https://img.shields.io/badge/SCH-PDF-f3cd5a?longCache=true&style=flat-rounded)](https://github.com/picolemon/picofabric-hardware/blob/main/doc/sch.pdf)
[![Store](https://img.shields.io/badge/Store-PicoLemon-f3cd5a?longCache=true&style=flat-rounded)](http://picolemon.com/board/PICOFABRIC)
[![Examples](https://img.shields.io/badge/Code-Examples-f3cd5a?longCache=true&style=flat-rounded)](https://github.com/picolemon/picofabric-examples)
[![Discord](https://img.shields.io/badge/@-Discord-f3cd5a?longCache=true&style=flat-rounded)](https://discord.gg/Be3yFCzyrp)

### Description :hammer:

This repo contains a small set of examples for running on the PicoFabric FPGA development board. 

## Related Libraries & Software
- [x] [Pico Fabric IDE](https://github.com/picolemon/picofabric-ide) Visual Studio Code based simulator, builder & programmer.
- [x] [PicoFabric MicroPython library](https://github.com/picolemon/picofabric-micropython)
- [x] [PicoFabric C/C++ library](https://github.com/picolemon/picofabric-c)

## Micro Python Examples

Micro Python is used to upload the bit stream and provide a repl environment for rapid testing.

- [x] [spi_slave](micropython/spi_slave/)
- [x] [serial_echo](micropython/serial_echo/)
- [x] [sdcard_passthrough](micropython/sdcard_passthrough/)
- [x] [dac_passthrough](micropython/sdcard_passthrough/)

## VHDL Examples

Most of the examples are written in VHDL and provide a testbench. The Pico is used purely as a programmer but can be used as a host process using the c sdk

- [x] [blinky](rtl/blinky/)
- [x] [memtest_hyperram](rtl/memtest_hyperram/)
- [x] [dvi_output](rtl/dvi_output)

### Getting started :mag:
Download the repo and open an example inside Visual Studio code ```Open in folder -> rtl/blinky``` then follow the readme for instructions how to run the example.

### Support :zap:
- Drop by the [discord](https://discord.gg/Be3yFCzyrp)
- Email help@picolemon.com

### License :penguin:
 
The MIT License (MIT)

Copyright (c) 2023 picoLemon

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
