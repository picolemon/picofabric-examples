# DVI Output :lemon: # 

### Overview :hammer:
Minimal DVI Video output example, generates a usable VGA signal and is converted to DVI. This uses the VGA & PLL wizard feature of the PicoFabric IDE to generate the timings and code templates.

### Whats included :musical_note:
- [x] 800x600 resolution.
- [x] Tested at 1280x720, close to the FPGA frequency limits.
- [x] Testcard with 100x100 moving box to visualize resolution & refresh rate.

### Preparation :mag:
Install the [Pico Fabric IDE](https://github.com/picolemon/picofabric-ide) Visual Studio Code extension.


### Building & Running :dolphin:
- Build the project using the following
```
(Ctrl + Shift + P) -> Build project bit stream and program device
```

### Changing the resolution :dolphin:
- Use the ECP5 VGA Wizard using the following command, this generates two files, a clocks.sv, clocks.vhd and a vga.vhd.
```
(Ctrl + Shift + P) -> Picofabric : Run tool wizard -> ECP5 VGA Wizard
```
- Enter a valid screen width eg. 1280
- Enter a valid screen height eg. 1280
- Enter a valid screen refresh rate eg. 60
- Use prefilled output filename eg. /vhd/vga.vhd
- Follow the steps for the PLL wizard, all the correct values should be pre-filled to match the VGA requirements.
- Save generated code and build & run.
- Update the width & height constants in top.vhd to match the new resolution.