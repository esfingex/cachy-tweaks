#!/bin/bash
# ==============================================================================
#   cachy-gnome-tweaks - scripts/laptop-tuning.sh
#   Purpose: Laptop & Thermal Tuning (ASUS ROG/TUF tools & Intel thermald)
# ==============================================================================
set -euo pipefail

# ANSI color codes
CYAN="\e[1;36m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
RESET="\e[0m"

log_info() { echo -e "${CYAN}[*] $1${RESET}"; }
log_success() { echo -e "${GREEN}[+] $1${RESET}"; }
log_warn() { echo -e "${YELLOW}[!] $1${RESET}"; }
log_error() { echo -e "${RED}[ERROR] $1${RESET}" >&2; }

# Pre-checks
if [ "$EUID" -ne 0 ]; then
    log_error "This script module must be run as root (sudo)."
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
if [ "$TARGET_USER" = "root" ]; then
    TARGET_HOME="/root"
else
    TARGET_HOME="/home/$TARGET_USER"
fi

# Detect desktop environment
IS_KDE=false
IS_GNOME=false
if [[ "${XDG_CURRENT_DESKTOP:-}" == *"KDE"* ]]; then
    IS_KDE=true
elif [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]]; then
    IS_GNOME=true
fi

log_info "Starting ASUS Laptop & Intel CPU Thermal optimization for user '${TARGET_USER}'..."

# 1. Install required packages (asusctl, thermald)
log_info "Installing ASUS control utilities and Intel thermal daemon..."
if pacman -S --needed --noconfirm asusctl thermald; then
    log_success "Successfully installed asusctl and thermald."
else
    log_error "Failed to install required hardware packages. Verify your internet connection."
    exit 1
fi

# 2. Configure and enable ASUS power & RGB daemon (asusd)
log_info "Configuring and enabling ASUS hardware daemon (asusd)..."
# Fix known systemd namespace bug by ensuring /etc/asusd exists
mkdir -p /etc/asusd
# Reset any previous systemd start limit failures to bypass rate limits
systemctl reset-failed asusd.service 2>/dev/null || true
systemctl enable --now asusd.service 2>/dev/null || log_warn "Could not enable/start asusd.service."
log_success "ASUS hardware daemon (asusd) is active."

# 3. Stop, disable and remove legacy supergfxctl if present
log_info "Checking for legacy supergfxctl daemon..."
if systemctl is-active --quiet supergfxd.service || systemctl is-enabled --quiet supergfxd.service 2>/dev/null; then
    log_warn "Disabling and stopping legacy supergfxd.service..."
    systemctl disable --now supergfxd.service 2>/dev/null || true
fi
if pacman -Qi supergfxctl &>/dev/null; then
    log_warn "Removing legacy supergfxctl package..."
    pacman -Rns --noconfirm supergfxctl || true
fi

# Install envytweaks GPU switcher
log_info "Installing GPU mode switcher (envytweaks) from repository..."
TEMP_DIR=$(mktemp -d)
if git clone --quiet https://github.com/esfingex/envytweaks.git "$TEMP_DIR"; then
    log_info "Running envytweaks installer..."
    # Run installer. Since we are root here, we pass SUDO_USER to install the extension for the user
    (cd "$TEMP_DIR" && export SUDO_USER="${TARGET_USER}" && ./install.sh)
    log_success "Successfully installed envytweaks."
else
    log_error "Failed to clone envytweaks repository. GPU switcher not installed."
fi
rm -rf "$TEMP_DIR"

# 4. Configure and enable Intel active thermal management daemon (thermald)
log_info "Configuring and enabling Intel thermal daemon (thermald)..."
systemctl enable --now thermald.service 2>/dev/null || log_warn "Could not enable/start thermald.service."
log_success "Intel active thermal daemon (thermald) is active."

# 5. Clean up legacy GPU Switcher GNOME extension if present
if $IS_GNOME; then
    LEGACY_UUID="gpu-switcher-supergfxctl@chikobara.github.io"
    LEGACY_DIR="${TARGET_HOME}/.local/share/gnome-shell/extensions/${LEGACY_UUID}"
    if [ -d "$LEGACY_DIR" ]; then
        log_warn "Removing legacy GPU Switcher GNOME extension..."
        rm -rf "$LEGACY_DIR"
    fi
    
    # Enable the newly installed envytweaks extension
    if [ "$TARGET_USER" != "root" ]; then
        log_info "Enabling envytweaks GNOME Shell extension for ${TARGET_USER}..."
        # Run as the target user to modify their GNOME extension settings
        su - "${TARGET_USER}" -c "gnome-extensions enable envytweaks@cachyos.org" 2>/dev/null || log_warn "Could not auto-enable envytweaks extension. Please enable it manually."
    fi
fi

log_success "Laptop & Thermal Tuning optimizations applied successfully!"

# Output helpful CLI commands for user reference
echo -e "\n${YELLOW}💡 Useful Commands & Usage Reference:${RESET}"
echo -e "  - ${CYAN}asusctl profile -n${RESET}              : Toggle power profiles (Silent, Balanced, Turbo)"
echo -e "  - ${CYAN}envytweaks -q${RESET}                   : Show current active GPU mode"
echo -e "  - ${CYAN}envytweaks -s <Mode>${RESET}            : Switch GPU mode (hybrid, integrated, nvidia)"
echo -e "  - ${CYAN}systemctl status thermald${RESET}       : Check the active Intel thermal controller status"
echo -e "${YELLOW}Note: Some GPU switching actions through envytweaks require you to restart your system to apply changes.${RESET}\n"
