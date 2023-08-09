# dac_passthrough :lemon: # 

### Overview :hammer:
Plays audio on the DAC wired through FPGA fabric.
- Pico SPI -> FPGA -> DAC SPI control port
- Pico I2S -> FPGA -> DAC I2S interface
- FPGA 12Mhz clock -> DAC snd_scki


### Whats included :musical_note:
- [x] DAC initialization.
- [x] SPI DAC command routing.
- [x] I2S Audio output routing.
- [x] Wave player streamed from Pico Flash storage.

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
- Add "wav" to the sync file type.

Upload the bitStream and libfabric files to the Pico device.
```
(Ctrl + Shift + P) -> MicroPython: Upload Project to Pico
```

Open ```play_wav.py```


:warning: Volume warning when using headphones :warning:

Plugin some speakers or headphones into the 3mm audio output jack.

Press ```Run``` on the bottom toolbar.

The Pico (SPI master) will send SPI commands to initialize the DAC and stream a tone over I2S

```
>>> 
Init DAC...
Playing wav...
```

## DAC Datasheet reference:
[PCM1774 Datasheet](https://www.ti.com/lit/gpn/pcm1774) 

## Licenses:
waveplayer.py [MIT] credit: https://github.com/miketeachman/micropython-i2s-examples/	
