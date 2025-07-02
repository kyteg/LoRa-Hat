import adafruit_rfm9x
import busio
from digitalio import DigitalInOut, Direction, Pull
import board

CS = DigitalInOut(board.CE1)
RESET = DigitalInOut(board.D25)
spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
rfm9x = adafruit_rfm9x.RFM9x(spi, CS, RESET, 915.0)

print("Waiting to receive transmission...")

while True:
        try:
            data = rfm9x.receive(timeout=100.0)
            if data is not None:
                try:
                    print(f"[Received] {data.decode('utf-8')} (RSSI:{rfm9x.rssi})")
                except UnicodeDecodeError:
                    print("Received undecodable data:", data)
        except KeyboardInterrupt:
            break