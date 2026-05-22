#!/bin/bash
# ==============================================================================
#   cachy-gnome-tweaks - scripts/starship.sh
#   Purpose: Install and configure Starship shell prompt optional module
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

log_info "Initiating Starship Prompt setup for user '${TARGET_USER}'..."

# 1. Install Starship
log_info "Installing starship via pacman..."
pacman -S --needed --noconfirm starship || log_warn "Could not install starship automatically."

# 2. Configure Starship
log_info "Deploying Starship configuration..."
CONFIG_DIR="${TARGET_HOME}/.config"
mkdir -p "$CONFIG_DIR"
chown "${TARGET_USER}:${TARGET_USER}" "$CONFIG_DIR"

STARSHIP_SRC="/home/athena/Github/cachy-gnome-tweaks/config/starship.toml"
STARSHIP_DST="${CONFIG_DIR}/starship.toml"

if [ -f "$STARSHIP_SRC" ]; then
    cp "$STARSHIP_SRC" "$STARSHIP_DST"
    chown "${TARGET_USER}:${TARGET_USER}" "$STARSHIP_DST"
    log_success "Copied elegant Starship layout to ${STARSHIP_DST}"
else
    log_warn "Source starship.toml not found at ${STARSHIP_SRC}."
fi

# 3. Inject shell activation shims
log_info "Registering shell activation scripts for Starship..."

# --- BASH CONFIGURATION ---
BASHRC="${TARGET_HOME}/.bashrc"
if [ -f "$BASHRC" ]; then
    log_info "Injecting environment hooks into ${BASHRC}..."
    
    # Remove older hooks or blocks safely
    sed -i '/# <<< cachy-gnome-tweaks STARSHIP START <<<$/,/# >>> cachy-gnome-tweaks STARSHIP END >>>$/d' "$BASHRC"
    sed -i '/starship init bash/d' "$BASHRC"
    
    # Append fresh shims in a clean block
    cat << 'EOF' >> "$BASHRC"

# <<< cachy-gnome-tweaks STARSHIP START <<<
# cachy-gnome-tweaks: Starship shell prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
# >>> cachy-gnome-tweaks STARSHIP END >>>
EOF
    log_success "Bash configurations injected."
else
    log_info "No .bashrc file detected for '${TARGET_USER}'."
fi

# --- FISH CONFIGURATION ---
FISH_CONF="${CONFIG_DIR}/fish/config.fish"
if [ -d "${CONFIG_DIR}/fish" ] || [ -f "$FISH_CONF" ]; then
    log_info "Injecting environment hooks into ${FISH_CONF}..."
    mkdir -p "$(dirname "$FISH_CONF")"
    chown -R "${TARGET_USER}:${TARGET_USER}" "${CONFIG_DIR}/fish"
    
    # Touch file if not exists
    if [ ! -f "$FISH_CONF" ]; then
        touch "$FISH_CONF"
        chown "${TARGET_USER}:${TARGET_USER}" "$FISH_CONF"
    fi
    
    # Clean previous blocks safely
    sed -i '/# <<< cachy-gnome-tweaks STARSHIP START <<<$/,/# >>> cachy-gnome-tweaks STARSHIP END >>>$/d' "$FISH_CONF"
    sed -i '/starship init fish/d' "$FISH_CONF"
    
    # Append fresh fish shims in a clean block
    cat << 'EOF' >> "$FISH_CONF"

# <<< cachy-gnome-tweaks STARSHIP START <<<
# cachy-gnome-tweaks: Starship shell prompt
if status is-interactive
    if type -q starship
        starship init fish | source
    end
end
# >>> cachy-gnome-tweaks STARSHIP END >>>
EOF
    log_success "Fish configurations injected."
else
    log_info "Fish shell layout directory not active."
fi

log_success "Starship Prompt applied successfully!"
