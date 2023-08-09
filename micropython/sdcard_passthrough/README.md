# sdcard_passthrough :lemon: # 

### Overview :hammer:
Reads and writes files from the built-in SD card reader. Routes through the FPGA to the Pico which implements the filesystem logic using standard Micro Python libraries.

### Whats included :musical_note:
- [x] SD card physical interface routing from Pico through FPGA to SD card.
- [x] Read & writes file to SD card.

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
(Ctrl + Shift + P) -> MicroPython: Connect
```

Setup project sync settings.
```
(Ctrl + Shift + P) -> MicroPico: Workspace settings -> micropico.syncFileType
```
- Remove "json" from the sync file types.
- Add "bit" to the sync file type.

Upload the bitStream and libfabric files to the Pico device.
```
(Ctrl + Shift + P) -> MicroPython: Upload Project to Pico
```

Open ```test_sdcard.py```

Insert a FAT32 formatted SD Card into card reader on the bottom side of the board.

Press ```Run``` on the bottom toolbar.

The Pico will mount the SD card and write a test file then read back.

```
>>> 
Mounting SDCARD...
Detected: True, Connected: True, Mounted: False
/sd Mounted
Writing...
Reading back...
Got: Hello World
```

## Licenses:
sdcard.py [MIT] credit: https://github.com/OneMadGypsy/pico-sd-card
