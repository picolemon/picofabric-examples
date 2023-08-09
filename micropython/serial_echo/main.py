"""
Sends data from Pico UART to FPGA, FPGA echos back to Pico.

- Inits UART 1 on GPIO 4&5
- Uploads FPGA echo bitstream, this listens on UART and echo back at 19200 baud
- Pico listens on core1 for data from FPGA
"""
from time import sleep
import _thread
from machine import Pin,UART
import time
import libfabric

uart = UART(1, baudrate=19200, tx=Pin(4), rx=Pin(5))
uart.init(bits=8, parity=None, stop=1)

# upload logic, simple uart echo
libfabric.fpga_program_device("gen/hardware.bit")

# UART listen thread
thread = None
def core0_thread(uart):    
    while True:
        if uart.any(): 
            data = uart.read() 
            print("FPGA Echoed:", data)

thread = _thread.start_new_thread(core0_thread, (uart,))

# main
while True:
    # send to FPGA
    sendTxt = input("")
    uart.write(sendTxt)