#!/bin/bash
# ==============================================================================
#   cachy-gnome-tweaks - scripts/nvidia.sh
#   Purpose: NVIDIA Wayland & Electron hardware acceleration tuning module
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

log_info "Starting NVIDIA & Wayland Hardware Acceleration setup..."

# Check if NVIDIA hardware is present
if ! lspci | grep -qi nvidia; then
    log_warn "No NVIDIA hardware detected in lspci. Proceeding anyway by user request..."
else
    log_success "NVIDIA hardware detected."
fi

# Target file for environment variables
ENV_FILE="/etc/environment"
backup_created=false

# Helper to inject variables idempotently
inject_env() {
    local key="$1"
    local val="$2"
    
    # Create backup of /etc/environment once
    if [ "$backup_created" = false ]; then
        cp "$ENV_FILE" "${ENV_FILE}.backup-tweaks"
        backup_created=true
        log_info "Created backup of ${ENV_FILE} at ${ENV_FILE}.backup-tweaks"
        # Ensure target file has a proper trailing newline to avoid append corruption
        if [ -f "$ENV_FILE" ] && [ -n "$(tail -c 1 "$ENV_FILE" 2>/dev/null)" ]; then
            echo "" >> "$ENV_FILE"
        fi
    fi

    if grep -q "^${key}=" "$ENV_FILE"; then
        # Update existing variable safely
        sed -i "s|^${key}=.*|${key}=${val}|" "$ENV_FILE"
        log_info "Updated: ${key}=${val}"
    else
        # Append new variable
        echo "${key}=${val}" >> "$ENV_FILE"
        log_success "Added: ${key}=${val}"
    fi
}

# Apply optimal variables for flawless Wayland/Electron GPU rendering
inject_env "__GLX_VENDOR_LIBRARY_NAME" "nvidia"
inject_env "GBM_BACKEND" "nvidia-drm"
inject_env "NVD_BACKEND" "direct"
inject_env "ELECTRON_OZONE_PLATFORM_HINT" "auto"

log_success "Environment variables successfully configured in ${ENV_FILE}."

# Setup Chromium / Chrome hardware video decoding support
log_info "Configuring Chromium / Chrome hardware acceleration shims..."
CHROME_FLAGS_FILE="/home/${SUDO_USER:-$USER}/.config/chromium-flags.conf"
CHROME_FLAGS_DIR=$(dirname "$CHROME_FLAGS_FILE")

mkdir -p "$CHROME_FLAGS_DIR"
chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$CHROME_FLAGS_DIR"

FLAG="--enable-features=VaapiOnNvidiaGPUs"
if [ -f "$CHROME_FLAGS_FILE" ]; then
    if ! grep -qF -- "$FLAG" "$CHROME_FLAGS_FILE"; then
        echo "$FLAG" >> "$CHROME_FLAGS_FILE" # Append
        log_success "Added Vaapi flag to existing chromium-flags.conf"
    else
        log_info "Chromium VA-API flags already configured."
    fi
else
    echo "$FLAG" > "$CHROME_FLAGS_FILE"
    chown "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$CHROME_FLAGS_FILE"
    log_success "Created chromium-flags.conf with VA-API enabled."
fi

# Setup NVIDIA kernel module parameters (modprobe)
log_info "Configuring NVIDIA kernel module options..."
TWEAKS_CONF="/etc/modprobe.d/nvidia-tweaks.conf"
cat << 'EOF' > "$TWEAKS_CONF"
# Configuration file created by cachy-tweaks

# Enable PreserveVideoMemoryAllocations for Wayland suspend/resume stability
# Enable EnableStreamMemOPs=1 for CUDA stream memory operations
# Enable RMIntrLockingMode=1 for low-latency frame presentation (driver 570+)
# Enable EnableResizableBar=1 for Resizable BAR support
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_EnableStreamMemOPs=1 NVreg_RegistryDwords=RMIntrLockingMode=1 NVreg_EnableResizableBar=1

# Enable modesetting for nvidia_drm (critical for Wayland/PRIME)
options nvidia_drm modeset=1
EOF
log_success "Configured NVIDIA driver options in ${TWEAKS_CONF}"

# Clean up legacy power management file if present (consolidated into nvidia-tweaks.conf)
if [ -f "/etc/modprobe.d/nvidia-power-management.conf" ]; then
    rm -f "/etc/modprobe.d/nvidia-power-management.conf"
    log_info "Removed legacy /etc/modprobe.d/nvidia-power-management.conf file."
fi

# Enable required NVIDIA systemd suspend/hibernate/resume services
log_info "Enabling systemd suspension and power services for NVIDIA..."
systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service 2>/dev/null || log_warn "Could not enable NVIDIA systemd suspend/resume services."

# Enable nvidia-powerd if supported/present (for laptop TDP Dynamic Boost)
if systemctl list-unit-files | grep -q "^nvidia-powerd.service"; then
    systemctl enable nvidia-powerd.service 2>/dev/null || log_warn "Could not enable nvidia-powerd.service."
    log_success "Enabled nvidia-powerd.service for Dynamic Boost."
fi

# Setup Firejail compatibility if Firejail is present
if command -v firejail &>/dev/null; then
    log_info "Firejail detected. Configuring NVIDIA acceleration compatibility rules..."
    fj_user="${SUDO_USER:-$USER}"
    if [ "$fj_user" != "root" ]; then
        fj_dir="/home/${fj_user}/.config/firejail"
        mkdir -p "$fj_dir"
        fj_file="${fj_dir}/globals.local"
        
        # Append rules if not already present
        for rule in "noblacklist /sys/module" "whitelist /sys/module/nvidia*" "read-only /sys/module/nvidia*"; do
            if [ -f "$fj_file" ] && grep -qF "$rule" "$fj_file"; then
                continue
            fi
            echo "$rule" >> "$fj_file"
        done
        chown -R "${fj_user}:${fj_user}" "$fj_dir"
        log_success "Firejail compatibility rules configured in ${fj_file}"
    fi
fi

# Detect desktop environment and configure GNOME settings
TARGET_USER="${SUDO_USER:-$USER}"
if [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]]; then
    if [ "$TARGET_USER" != "root" ]; then
        log_info "GNOME desktop detected. Configuring GNOME environment..."
        
        # User session helper function for running gsettings
        run_user_gsettings() {
            local uid
            uid=$(id -u "$TARGET_USER")
            sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" gsettings "$@"
        }

        run_user_gsettings set org.gnome.shell always-show-log-out true 2>/dev/null || log_warn "Could not enable always-show-log-out setting."
        
        # Detect VRR (Variable Refresh Rate) capability
        has_vrr=false
        if command -v edid-decode &>/dev/null; then
            for edid in /sys/class/drm/*/edid; do
                if edid-decode "$edid" >/dev/null 2>&1; then
                    if edid-decode "$edid" 2>/dev/null | grep -qiE "vrr|freesync|range limits|minimum refresh rate"; then
                        has_vrr=true
                        break
                    fi
                fi
            done
        else
            if grep -q "1" /sys/class/drm/*/vrr_capable 2>/dev/null; then
                has_vrr=true
            fi
        fi

        if [ "$has_vrr" = true ]; then
            log_info "VRR-capable monitor detected!"
            # In GNOME 50+, VRR is stable and no longer an experimental feature. We only set the experimental flag if the schema requires it.
            if run_user_gsettings range org.gnome.mutter experimental-features 2>/dev/null | grep -q "variable-refresh-rate"; then
                current_features=$(run_user_gsettings get org.gnome.mutter experimental-features 2>/dev/null || echo "@as []")
                if [[ "$current_features" != *"'variable-refresh-rate'"* ]]; then
                    log_info "Enabling GNOME Variable Refresh Rate (VRR) experimental feature..."
                    if [[ "$current_features" == "@as []" || "$current_features" == "[]" ]]; then
                        run_user_gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']" 2>/dev/null || log_warn "Could not enable VRR."
                    else
                        new_features="${current_features%]*}, 'variable-refresh-rate']"
                        run_user_gsettings set org.gnome.mutter experimental-features "$new_features" 2>/dev/null || log_warn "Could not enable VRR."
                    fi
                    log_success "GNOME VRR experimental feature enabled! Log out and log back in to apply, then activate it in Settings -> Displays."
                else
                    log_success "GNOME Variable Refresh Rate (VRR) experimental feature is already enabled."
                fi
            else
                log_success "GNOME Variable Refresh Rate (VRR) is supported natively on your system. You can configure it directly in Settings -> Displays."
            fi
        fi
    fi
fi

log_success "NVIDIA & Wayland acceleration module applied successfully!"
echo -e "\n${YELLOW}💡 Note: Please restart your session (log out and log in) to apply environment changes.${RESET}\n"
