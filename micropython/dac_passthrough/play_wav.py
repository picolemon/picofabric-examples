import time, machine
from wavplayer import WavPlayer
import libfabric

# init FPGA
libfabric.fpga_program_device("gen/hardware.bit")

# init DAC
print("Init DAC...")
dac_config = libfabric.DACConfig()
libfabric.dac_init(dac_config)

# Create waveplayer with default pins from DACConfig
wp = WavPlayer(
    id=dac_config.i2s_id,
    sck_pin=machine.Pin(dac_config.i2s_sck),
    ws_pin=machine.Pin(dac_config.i2s_ws),
    sd_pin=machine.Pin(dac_config.i2s_sd),
    ibuf=40000,
    root="/"
)

print("Playing wav...")
wp.play("tone16k-stereo.wav", loop=False)
