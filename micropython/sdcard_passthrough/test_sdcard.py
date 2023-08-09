import sdcard
import libfabric

# init FPGA passthrough
libfabric.fpga_program_device("gen/hardware.bit")

print("Mounting SDCARD...")
sd = sdcard.SDCard(spi=0, sck=2, mosi=3, miso=4, cs=5, automount=0)
sd.state()
sd.mount()

# write file
print("Writing...")
with open("{}/test.txt".format(sd.drive), 'w') as f:
    f.write('Hello World')

# read & echo back
print("Reading back...")
with open("{}/test.txt".format(sd.drive), 'r') as f:
    print("Got:", f.read() )