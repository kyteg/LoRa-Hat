#!/usr/bin/env bash
set -euo pipefail

CONFIG_TXT="/boot/firmware/config.txt"
MESH_DIR="/etc/meshtasticd"
MESH_CONFIG="${MESH_DIR}/config.yaml"
SERVICE_NAME="meshtasticd"

echo "[*] Checking for root..."
if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo."
  exit 1
fi

echo "[*] Updating package lists..."
apt update

echo "[*] Installing required packages..."
apt install -y meshtasticd

echo "[*] Ensuring SPI is enabled in ${CONFIG_TXT}..."

# Ensure dtparam=spi=on exists and is uncommented
if grep -Eq '^\s*#\s*dtparam=spi=on' "${CONFIG_TXT}"; then
  sed -i 's/^\s*#\s*dtparam=spi=on/dtparam=spi=on/' "${CONFIG_TXT}"
elif ! grep -Eq '^\s*dtparam=spi=on' "${CONFIG_TXT}"; then
  echo 'dtparam=spi=on' >> "${CONFIG_TXT}"
fi

# Remove any existing spi0-*cs overlay lines to avoid conflicts
sed -i '/^\s*dtoverlay=spi0-.*cs\s*$/d' "${CONFIG_TXT}"

# Add the overlay needed for manual CS via GPIO7 while using /dev/spidev0.0
echo 'dtoverlay=spi0-0cs' >> "${CONFIG_TXT}"

echo "[*] Creating meshtastic config directory..."
mkdir -p "${MESH_DIR}"

echo "[*] Backing up existing config if present..."
if [[ -f "${MESH_CONFIG}" ]]; then
  cp "${MESH_CONFIG}" "${MESH_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
fi

echo "[*] Writing ${MESH_CONFIG}..."
cat > "${MESH_CONFIG}" <<'YAML'
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
  Port: 443
  RootPath: /usr/share/meshtasticd/web
YAML

echo "[*] Enabling meshtasticd service..."
systemctl enable "${SERVICE_NAME}"

echo
echo "========================================"
echo "Meshtastic setup complete!"
echo

echo "Please reboot now to apply SPI changes:"
echo
echo "  sudo reboot"
echo

# Get primary IP (works on most Pi setups)
IP=$(hostname -I | awk '{print $1}')

echo "After reboot, access the web UI at:"
echo
if [ -n "$IP" ]; then
  echo "  http://$IP"
else
  echo "  http://<your-pi-ip>"
fi

echo "========================================"
echo
