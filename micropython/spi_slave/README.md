# spi_slave :lemon: # 

### Overview :hammer:
Implements an SPI Slave device on the FPGA with a simple command dispatcher. The example writes a value to the a register on the FPGA and reads it back.

### Whats included :musical_note:
- [x] SPI slave wired over GPIO.
- [x] Cross clock domain, SPI can be clocked independent of default FPGA 48Mhz interface clock.
- [X] Command dispatcher reads a command from the first byte and reacts with a response on the subsequent bytes output on the MISO line.

### Preparation :mag:
[Pico Fabric IDE](https://github.com/picolemon/picofabric-ide) Visual Studio Code extension.

[MicroPython](https://marketplace.visualstudio.com/items?itemName=paulober.pico-w-go) Visual Studio Code extension.

Install a [MicroPython](https://micropython.org/) UF2 image to the Pico micro controller using BOOTSEL mode.

### Building & Running :dolphin:
- Build the project bitStream using the following.
```
(Ctrl + Shift + P) -> Build project bit stream
```

Connect to the MicroPython enabled device.
```
(Ctrl + Shift + P) -> MicroPico: Connect
```

Setup project sync settings.
```
(Ctrl + Shift + P) -> MicroPico: Workspace settings -> micropico.syncFileType
```
- Remove "json" from the sync file types.
- Add "bit" to the sync file type.

Upload the bitStream and libfabric files to the Pico device.
```
(Ctrl + Shift + P) -> MicroPico: Upload Project to Pico
```

Open ```main.py```

Press ```Run``` on the bottom toolbar.

The Pico (SPI master) will send SPI commands to the FPGA and validate the response, there are 3 commands send which test write a register on the device.

```
>>> 
Status cmd...
Got: 0b10000000
Write value...
Read value...
Got: 0b11110011
```