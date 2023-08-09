# serial_echo :lemon: # 

### Overview :hammer:
The Serial interface example echos back serial data sent by a host. This implements a serial UART reciever on the FPGA and UART transmitter, the logic will detect a new byte and transmit it back to the Pico device, the Pico will recieve and echo into the Host repl environment.

### Whats included :musical_note:
- [x] Serial UART fixed at 19200 Baud
- [x] MicroPython communication to FPGA & pc host.

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

Open ```main.py```

Press ```Run``` on the bottom toolbar.

Entering text in the Pico(W) Repl Terminal window and press return and the text should echo back. 
```
$ FPGA Echoed: b'Hello world'
```