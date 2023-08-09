"""
SPI master to slave communication, interfaces with the spi_echo_ctrl running on the FPGA.
- Dispatches commands and reads back the result.
"""
import machine, time
import libfabric

# SPI commands
CMD_STATUS = 0x01
CMD_WRITE_REG0 = 0x02
CMD_READ_REG0 = 0x03

# create IO pins
sck = machine.Pin(2, machine.Pin.OUT)
mosi = machine.Pin(3, machine.Pin.OUT)
miso = machine.Pin(4, machine.Pin.IN)
csn = machine.Pin(5, machine.Pin.OUT)

# create SPI instance (slow and safe, tested up to 50 mhz)
spi = machine.SPI(0,
            baudrate=1000000, 
            polarity=0,
            phase=1,
            bits=8,
            firstbit=machine.SPI.MSB,
            sck=sck,
            mosi=mosi,
            miso=miso)

# upload bitstream to FPGA
libfabric.fpga_program_device("gen/hardware.bit")

# init spi state
csn.value(1)
time.sleep(0.1)


print("Status cmd...")
# test read status
dataout = [
    CMD_STATUS # Cmd
]
sz = 1
csn.value(0)
spi.write(bytearray(dataout));
result = spi.read(sz);
csn.value(1)
statusVal = result[0]
print("Got:", bin(statusVal))
assert statusVal == 0b10000000, "Invalid status response"


# test write value to reg0 over spi, cmd dispatcher will save value into a hw register
print("Write value...")    
dataout = [
    CMD_WRITE_REG0, # Cmd
    0b11110011  # Value to store in reg0
]
sz = 1
csn.value(0)
spi.write(bytearray(dataout));    
csn.value(1)


print("Read value...")       
# readback register from spi cmd dispatcher
dataout = [
    CMD_READ_REG0 # Read
]
sz = 1
csn.value(0)
spi.write(bytearray(dataout));
result = spi.read(sz);
csn.value(1)

regVal = result[0]
print("Got:", bin(regVal))
assert regVal == 0b11110011, "Invalid reg0 value"

