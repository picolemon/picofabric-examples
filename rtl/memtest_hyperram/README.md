# Memtest HyperRAM :lemon: # 

### Overview :hammer:
Very simple HyperRAM tester, writes values to the ram and reads back to tests its functionality and provides a reference HyperRAM controller for accessing the memory devices.

### Whats included :musical_note:
- [x] Tests single memory device
- [x] Test status reported via LEDs
- [x] Serial test output

### Preparation :mag:
Install the [Pico Fabric IDE](https://github.com/picolemon/picofabric-ide) Visual Studio Code extension.


### Building & Running :dolphin:
- Build the project using the following
```
(Ctrl + Shift + P) -> Build project bit stream and program device
```
- LED blinks on failure, stays on for success.
- UART at 19200 BAUD is available on Pin 1 (PLGP.IO0P1 or Pico  GPIO 0), this outputs a ASCII "1" for success or "0" for failure.