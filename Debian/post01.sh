#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
#  Debian 13 Post-Install Script
# ─────────────────────────────────────────────

# Safety: do not run as root directly
if [[ "$EUID" -eq 0 ]]; then
    echo "[!] Do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

echo "[*] Starting Debian 13 post-install setup..."

# ─────────────────────────────────────────────
#  System Update & Upgrade
# ─────────────────────────────────────────────
echo "[*] Updating system..."
sudo apt update -y && sudo apt upgrade -y

# ─────────────────────────────────────────────
#  Base Packages
# ─────────────────────────────────────────────
echo "[*] Installing base packages..."
sudo apt install -y \
    curl \
    git \
    open-vm-tools \
    open-vm-tools-desktop \
    pipx \
    php \
    build-essential \
    gnupg \
    openvpn \
    network-manager-openvpn-gnome \
    ptyxis \
    gnome-tweaks \
    fonts-hack \
    fonts-jetbrains-mono \
    papirus-icon-theme

# Make pipx binaries available in PATH
pipx ensurepath

# ─────────────────────────────────────────────
#  Node.js 22 LTS (via NodeSource)
# ─────────────────────────────────────────────
echo "[*] Installing Node.js 22 LTS..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs

# ─────────────────────────────────────────────
#  Go (latest, from official upstream)
# ─────────────────────────────────────────────
echo "[*] Installing Go (latest)..."

# Detect architecture
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) GO_ARCH=amd64 ;;
    arm64) GO_ARCH=arm64 ;;
    *) echo "[!] Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Fetch latest Go version string from the official API
GO_VERSION=$(curl -fsSL "https://go.dev/dl/?mode=json" | grep -oP '"version":\s*"\K[^"]+' | head -1)
GO_TARBALL="${GO_VERSION}.linux-${GO_ARCH}.tar.gz"

echo "[*] Downloading ${GO_TARBALL}..."
curl -fL -o "/tmp/${GO_TARBALL}" "https://go.dev/dl/${GO_TARBALL}"

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
rm -f "/tmp/${GO_TARBALL}"

# Add Go to PATH for the current user (idempotent)
GO_PATH_LINE='export PATH=$PATH:/usr/local/go/bin'
if ! grep -qF "$GO_PATH_LINE" "$HOME/.profile"; then
    echo "$GO_PATH_LINE" >> "$HOME/.profile"
fi
export PATH=$PATH:/usr/local/go/bin

echo "[*] Go installed: $(go version)"

# ─────────────────────────────────────────────
#  Brave Browser
# ─────────────────────────────────────────────
echo "[*] Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update -y
sudo apt install -y brave-browser

# ─────────────────────────────────────────────
#  VSCodium
# ─────────────────────────────────────────────
echo "[*] Installing VSCodium..."
wget -qO /tmp/vscodium.gpg \
    https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
gpg --dearmor < /tmp/vscodium.gpg \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
rm -f /tmp/vscodium.gpg

echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
    | sudo tee /etc/apt/sources.list.d/vscodium.sources > /dev/null

sudo apt update -y && sudo apt install -y codium

# ─────────────────────────────────────────────
#  Sublime Text
# ─────────────────────────────────────────────
echo "[*] Installing Sublime Text..."
sudo mkdir -p /etc/apt/keyrings
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
    | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null

echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' \
    | sudo tee /etc/apt/sources.list.d/sublime-text.sources > /dev/null

sudo apt update -y
sudo apt install -y sublime-text

# ─────────────────────────────────────────────
#  Burp Suite Community Edition
# ─────────────────────────────────────────────
echo "[*] Installing Burp Suite Community Edition..."

BURP_INSTALLER="/tmp/burpsuite_community_linux.sh"

curl -fL -o "$BURP_INSTALLER" \
    "https://portswigger.net/burp/releases/download?product=community&type=Linux"

chmod +x "$BURP_INSTALLER"

# Unattended install to default directory (/opt/BurpSuiteCommunity)
sudo "$BURP_INSTALLER" -q

rm -f "$BURP_INSTALLER"
echo "[*] Burp Suite installed. Launch via application menu or: /opt/BurpSuiteCommunity/BurpSuiteCommunity"

# ─────────────────────────────────────────────
#  Cleanup
# ─────────────────────────────────────────────
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo ""
echo "[✓] Post-install complete! Some PATH changes require a logout/login to take effect."
