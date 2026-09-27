#!/usr/bin/env sh
# Automated installer script for m-vis (Memory Visualizer) CLI on macOS and Linux.
#
# Usage (curl):
#   curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/SickleFire/m-vis/main/install.sh | sh
# Usage (wget):
#   wget -qO- https://raw.githubusercontent.com/SickleFire/m-vis/main/install.sh | sh

set -e

REPO="SickleFire/m-vis"
BINARY_NAME="mvis"
INSTALL_DIR="${MVIS_INSTALL_DIR:-$HOME/.local/bin}"

# Colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

printf "${CYAN}=== m-vis CLI Installer ===${NC}\n"

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     MACHINE="linux";;
    Darwin*)    MACHINE="macos";;
    *)
        printf "${RED}[ERROR] Unsupported operating system: $OS. Please download manually from https://github.com/$REPO/releases${NC}\n"
        exit 1
        ;;
esac

# Detect Architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)
        if [ "$MACHINE" = "macos" ]; then
            ASSET_NAME="mvis-macos-x86_64"
        else
            ASSET_NAME="mvis-linux-x86_64"
        fi
        ;;
    arm64|aarch64)
        if [ "$MACHINE" = "macos" ]; then
            ASSET_NAME="mvis-macos-aarch64"
        else
            printf "${RED}[ERROR] Unsupported architecture ($ARCH) for Linux. Currently x86_64 is supported for static releases.${NC}\n"
            exit 1
        fi
        ;;
    *)
        printf "${RED}[ERROR] Unsupported architecture: $ARCH${NC}\n"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$ASSET_NAME"

printf "${BLUE}Downloading m-vis from $DOWNLOAD_URL...${NC}\n"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TMP_FILE="$TMP_DIR/mvis"

if command -v curl >/dev/null 2>&1; then
    curl --fail --location --output "$TMP_FILE" "$DOWNLOAD_URL"
elif command -v wget >/dev/null 2>&1; then
    wget -O "$TMP_FILE" "$DOWNLOAD_URL"
else
    printf "${RED}[ERROR] Neither curl nor wget is available. Please install one and try again.${NC}\n"
    exit 1
fi

chmod +x "$TMP_FILE"

printf "${BLUE}Installing mvis to $INSTALL_DIR...${NC}\n"
mkdir -p "$INSTALL_DIR"
mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"

# Check if INSTALL_DIR is in PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        ;;
    *)
        printf "${BLUE}Adding $INSTALL_DIR to your shell profile...${NC}\n"
        SHELL_PROFILE=""
        if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
            SHELL_PROFILE="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
            SHELL_PROFILE="$HOME/.bashrc"
        elif [ -f "$HOME/.profile" ]; then
            SHELL_PROFILE="$HOME/.profile"
        fi

        if [ -n "$SHELL_PROFILE" ]; then
            if ! grep -q "$INSTALL_DIR" "$SHELL_PROFILE" 2>/dev/null; then
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_PROFILE"
                printf "${GREEN}[OK] Added export PATH to $SHELL_PROFILE${NC}\n"
            fi
        else
            printf "${YELLOW}[WARNING] Could not detect shell profile. Please add $INSTALL_DIR to your PATH manually.${NC}\n"
        fi
        ;;
esac

printf "\n${GREEN}=== Successfully installed m-vis CLI! ===${NC}\n"
printf "Installation Path: ${INSTALL_DIR}/${BINARY_NAME}\n"
printf "Run ${CYAN}mvis --help${NC} or ${CYAN}mvis tui${NC} to get started.\n"
