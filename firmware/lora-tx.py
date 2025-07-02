import time
import adafruit_rfm9x
import busio
from digitalio import DigitalInOut, Direction, Pull
import board

CS = DigitalInOut(board.CE1)
RESET = DigitalInOut(board.D25)
spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
rfm9x = adafruit_rfm9x.RFM9x(spi, CS, RESET, 915.0)
rfm9x.tx_power = 5 # Can be in range 5-23
# rfm9x.spreading_factor = 12  #  Can be 6, 7, 8, 9, 10, 11, or 12.

data=bytes("hello world","utf-8")

while True:
    rfm9x.send(data)
    print("data sent")
    time.sleep(3)