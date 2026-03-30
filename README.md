# Contact me
Discord - kyteg

# 👽 XenoLabs LoRa Raspberry Pi HAT

A compact, high-performance LoRa HAT for Raspberry Pi — designed for long-range wireless communication, custom mesh protocols, and rapid prototyping.

<img src="images/LoRa-Hat-on-Pi.jpg" alt="XenoLabs LoRa HAT" width="700"/>

## 🔧 Features

- Semtech SX1276/78 LoRa radio (RFM95W)
- Frequency: 915 MHz (AU/NZ/US)
- Fully compatible with Raspberry Pi 3/4/5
- 3.3V logic-level safe
- Low power consumption
- SMA antenna connector
- DIO breakout pins
- Jumpers to toggle direct connection to Pi GPIOs
- Designed by [XenoLabs](https://xeno-labs.io)

## 📦 Repository Contents
```
LoRa-Hat/
├── firmware/ # Example Python code
├── images/ # Photos and diagrams
└── README.md
```
## 🚀 Getting Started

### 🧰 Requirements

- Raspberry Pi 3, 4, or 5
- Python 3.7+
- LoRa HAT attached to GPIO header

### 📥 Install Dependencies

Install the Python dependencies
```bash
pip install adafruit-circuitpython-rfm9x
```
Enable SPI on Raspberry Pi
```bash
sudo raspi-config

-> 5 Interfacing Options -> P4 SPI -> <Yes>

sudo reboot
```

You can now run the demo (in the Firmware directory of this repo)!

For Transmitter:
```bash
python3 lora-tx.py
```

For Receiver:
```bash
python3 lora-rx.py
```

<img src="images/Lora-demo-code.jpg" alt="LoRa demo code" width="1000"/>

### 🛠️ Troubleshoot

If you get the error `lgpio.error: 'GPIO busy'` and `/dev/spidev0.1` is present when listing `/dev`

```bash
ls /dev/spidev*
/dev/spidev0.0  /dev/spidev0.1
```

SPI driver will not allow the code to use CE1.

Add the following line to `/boot/firmware/config.txt` and reboot.

```bash
dtoverlay=spi0-0cs
```

Ensure the output of `ls /dev/spidev*` does not contain `/dev/spidev0.1`

```bash
ls /dev/spidev*
/dev/spidev0.0
```

## 📌 Pinout

| Function | Pi GPIO Pin | Physical Pin | Notes                                           |
|----------|-------------|--------------|-------------------------------------------------|
| DIO0     | GPIO25      | 22           |                                                 |
| DIO1     | GPIO17      | 11           |                                                 |
| DIO3     | GPIO27      | 13           |                                                 |
| DIO4     | GPIO22      | 15           |                                                 |
| DIO5     | GPIO23      | 16           |                                                 |
| DIO6     | GPIO24      | 18           |                                                 |
| MOSI     | GPIO10      | 19           | SPI MOSI                                        |
| MISO     | GPIO9       | 21           | SPI MISO                                        |
| SCK      | GPIO11      | 23           | SPI Clock                                       |
| NSS      | GPIO7       | 26           | SPI Chip Select (CE1 / can be reassigned)       |
| RESET    | GPIO5       | 29           | LoRa reset pin                                  |

> **Note**: DIO pins can be disconnected from the Pi by removing the respective jumpers on the HAT.

## 📑 Referenfes

- RFM95W datasheet: https://cdn.sparkfun.com/assets/a/9/6/1/0/RFM95W-V2.0.pdf
- adafruit-circuitpython-rfm9x docs https://docs.circuitpython.org/projects/rfm9x/en/latest/api.html
- adafruit-circuitpython-rfm9x GitHub page https://github.com/adafruit/Adafruit_CircuitPython_RFM




## Getting Started with Meshtastic

This HAT is compatible with Meshtastic using the native Linux daemon (meshtasticd), allowing your Raspberry Pi to operate as a full-featured LoRa mesh node.

### Install Meshtastic Daemon
```bash
sudo apt update
sudo apt install meshtasticd
```

### Enable SPI
Ensure SPI is enabled:

```bash
sudo raspi-config
# Interface Options -> SPI -> Enable
sudo reboot
```

### Check we're using CE0

Ensure the output of `ls /dev/spidev*` does not contain `/dev/spidev0.1`

If it does, see the "Troubleshoot" section above and ensure the output of `ls /dev/spidev*` does not contain `/dev/spidev0.1`.

### Configure Meshtastic

Edit the configuration file:

```bash
sudo nano /etc/meshtasticd/config.yaml
```

Use the following configuration:

```bash
Lora:
  Module: RF95
  CS: 7
  IRQ: 25
  Reset: 5

SPI:
  Device: /dev/spidev0.0
  Speed: 125000
  GpioChip: /dev/gpiochip0

Webserver:
  Port: 443 # Port for Webserver & Webservices
  RootPath: /usr/share/meshtasticd/web # Root Dir of WebServer
```

### Start the Service
```bash
sudo systemctl enable meshtasticd
sudo systemctl start meshtasticd
```

Check logs:
```bash
journalctl -u meshtasticd -f
```

You should see the radio initialise successfully.

If not, make changes to the configuration and restart the meshtasticd service with: 
```bash
sudo systemctl daemon-reload
sudo systemctl restart meshtasticd
```

### Access the Web UI

Navigate to `https://[IP of your Raspberry Pi]`

Select "New Connection" and "connect" (Your Pi's IP address should be prefilled in the HTTP section)


### Install Meshtastic CLI
```bash
pip3 install meshtastic
```

### Initial Setup

Set region (Australia/New Zealand):
```bash
meshtastic --host localhost --set lora.region ANZ
```

Set default channel and modem preset:
```bash
meshtastic --host localhost --ch-longfast
```

Reboot the node:
```bash
meshtastic --host localhost --reboot
```


### Basic CLI commands

List nodes:
```bash
meshtastic --host localhost --nodes
```

Send a broadcast message:
```bash
meshtastic --host localhost --sendtext "Hello from XenoLabs Pi"
```

Listen for traffic:
```bash
meshtastic --host localhost --listen
```
