# 🏎️ cachy-tweaks

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CachyOS](https://img.shields.io/badge/OS-CachyOS%20%2F%20Arch%20Linux-blue.svg)](https://cachyos.org/)
[![GNOME](https://img.shields.io/badge/Desktop-GNOME%20%2F%20Wayland-green.svg)](https://www.gnome.org/)
[![KDE](https://img.shields.io/badge/Desktop-KDE%20%2F%20Wayland-blue.svg)](https://kde.org/)

An optimized, modular, and non-destructive performance tuning and developer environment suite tailored specifically for **CachyOS running GNOME or KDE Plasma**. 

This project isolates and refactors high-grade backend improvements (NVIDIA GPU hardware acceleration variables, network latency tweaks, automatic BTRFS Snapper backup hooks, inotify file-watcher expansions, and pre-configured developer runtime shims) into a clean, interactive selector menu.


---

## ✨ Features

`cachy-tweaks` is fully interactive and completely optional—you choose exactly what optimizations to apply:


* **⚡ Module 1: NVIDIA Wayland & Electron HW Acceleration**
  * Auto-detects NVIDIA hardware.
  * Injects critical Wayland environment overrides (`__GLX_VENDOR_LIBRARY_NAME`, `GBM_BACKEND`, `NVD_BACKEND`, `ELECTRON_OZONE_PLATFORM_HINT`) to solve lag, screen-tearing, and rendering stutter in modern Electron apps and flatpaks.
  * Auto-injects VA-API hardware video decoding flags for Chromium-based browsers.
  * Writes custom driver modprobe configurations to `/etc/modprobe.d/nvidia-tweaks.conf`:
    * `NVreg_PreserveVideoMemoryAllocations=1`: Stabilizes VRAM allocation during system suspension/resume under Wayland.
    * `NVreg_EnableStreamMemOPs=1`: Activates CUDA stream memory operations for compute/AI workloads.
    * `NVreg_RegistryDwords=RMIntrLockingMode=1`: Enables ultra-low-latency display interrupt locking mode (standard since driver 580.xx).
    * `NVreg_EnableResizableBar=1`: Enables motherboard/GPU Resizable BAR rendering memory performance.
    * `nvidia_drm modeset=1`: Core display modesetting parameter for Wayland and hybrid configurations.
  * Auto-enables specialized laptop GPU services (`nvidia-powerd.service` for dynamic TDP/Dynamic Boost) and registers Firejail sandbox NVIDIA hardware acceleration exceptions.
* **🌐 Module 2: Latency & Network Stability**
  * Configures advanced sysctl TCP MTU Probing and security parameters in `/etc/sysctl.d/99-cachy-gnome-tweaks.conf` to solve high-latency drops, protect against attacks, and prevent memory leaks.
  * Optimizes **Virtual Memory & Swap** configurations:
    * `vm.swappiness = 10`: Prefers physical RAM over swap disk paging to prevent SSD bottlenecks and stutter.
    * `vm.vfs_cache_pressure = 50`: Caches filesystem metadata structures (inodes/dentries) in RAM longer for snappy file browsing.
  * Automatically schedules **periodic SSD TRIM operations** (`fstrim.timer`) to maintain drive performance and write lifespan.
  * Masks slow network-waiting services to accelerate system boot times.
  * Safely migrates NetworkManager to use the modern, lightweight `iwd` Wi-Fi backend (if installed) for fast wireless roaming.
* **📂 Module 3: Linux File Watchers (inotify) Expansion**
  * Automatically elevates maximum watcher limits to `524288` and instances to `512` to prevent editor crashes or frozen builds in large projects (VS Code, Neovim, Webpack, Vite, Node).
* **🛡️ Module 4: Snapper BTRFS Automated Backups & Boot Rollbacks**
  * Sets up BTRFS subvolume timeline parameters with automatic Hourly Cleaners.
  * Integrates Snapper directly into `pacman` using `snap-pac` to take system-state snapshots before and after every software installation.
  * Enables the `grub-btrfs` service, allowing you to **boot directly into older snapshots** straight from the GRUB boot menu if an update ever breaks your user session.
* **🛠️ Module 5: Developer Core Stack**
  * Verifies or bootstraps `yay` AUR helper integration.
  * Installs and configures [tmux](https://github.com/tmux/tmux) with mouse support, intuitive panel splitting bindings, and ultra-fast escape-latency.
  * Registers environment shims for [mise](https://mise.jdx.dev/) runtime manager dynamically inside `.bashrc` and `config.fish`.
  * Installs lightweight, GPU-accelerated, and optimized developer tools: `kitty` (GPU terminal) and `micro` (modern text editor).
* **📦 Module 6: Premium Apps Bundle (Optional)**
  * Installs **Vivaldi Browser** along with proprietary media codecs, GNOME Shell browser connector integration (`gnome-browser-connector`), and automatically sets up hardware accelerated video decoding (VA-API) in Vivaldi configuration flags for seamless YouTube/video rendering.
  * Deploys the high-fidelity **Audio Stack & Bluetooth Codecs** (LDAC, aptX) alongside `pavucontrol` (volume mixer GUI) for superior sound stability and control.
  * Installs essential **Compression, Disk & Archive Utilities** (`zip`, `unzip`, `unrar`, `p7zip`, `gparted`) to enable partition management alongside seamless extraction of `.zip`, `.rar`, and `.7z` files directly inside GNOME's default file manager.
  * Installs **MenuLibre** desktop menu editor, allowing you to easily customize, edit, or clean up your GNOME applications menu shortcuts.
* **🚀 Module 7: Easyarch App Pack (Optional)**
  * Install your favorite tools interactively or via CLI arguments:
    * **Telegram Desktop** for communication.
    * **Wine & Gaming Core Pack**: Optimised `wine-cachyos` execution base, `wine-mono`/`wine-gecko`, `winetricks`, graphical companion tools (`protonup-qt`, `protontricks`), full `cachyos-gaming-meta` stack, GNOME shell GameMode status indicator extension, and essential multilib 32-bit & 64-bit graphics/audio rendering drivers.
    * **GitHub Desktop** client for GUI git operations.
    * **Google Chrome** browser.
    * **OnlyOffice** suite with Spanish spelling dictionary support (`hunspell-es`).
    * **Antigravity IDE Launcher**: Global command `antigravity` and a GNOME `.desktop` shortcut that launches VS Code hooked with a persistent workspace tmux terminal.
    * **qBittorrent**: Lightweight, ad-free, open-source BitTorrent client.
* **🖥️ Module 8: Virtualization Stack (Optional)**
  * Complete high-performance **KVM/QEMU** virtualization environment setup.
  * Installs `virt-manager` GUI, `dnsmasq`, bridge interfaces, and automatically registers the active user in the `libvirt` system group.
* **🐋 Module 9: Docker Stack (Optional)**
  * Installs **Docker Engine & Docker Compose**.
  * Registers user in the `docker` group and configures **NVIDIA CUDA Container Toolkit** runtime hooks directly inside `/etc/docker/daemon.json`.
* **🧹 Module 10: Bloatware Remover (Optional)**
  * Interactively purges unused pre-installed applications like **Alacritty**, **GNOME Web (Epiphany)**, **GNOME Tour**, and other redundant utilities to keep your desktop system light and clean.
  * Automatically runs `paccache` cleanup to delete old package archives from `/var/cache/pacman/pkg/`, retaining only the last two versions.
* **⚡ Module 11: makepkg Native Compiler & RAM-disk Optimization (Optional)**
  * Optimizes the Arch Linux compilation system (`/etc/makepkg.conf`) so that any package built from source (like emulators or AUR packages) compiles in a high-speed RAM-disk (`/tmp/makepkg`), utilizes all CPU cores/threads dynamically (`-j$(nproc)`), and leverages native processor instruction sets (`-march=native -O3`).
* **💻 Module 12: Laptop & Thermal Tuning (Optional)**
  * Auto-detects system manufacturer. Installs specialized utilities for ASUS laptops (`asusctl`) and the universal GPU switching suite (`envytweaks`) to manage power profiles, fan curves, keyboard backlights, and GPU switching (Hybrid, Integrated-only, Dedicated-only) directly on Linux. Supports both **GNOME Shell Extension** and **KDE Plasma 6 Widget** out of the box (only installs `asusctl` on ASUS hardware).
  * Installs Intel's active thermal management daemon (`thermald`) to pro-actively regulate CPU energy/temperatures, preventing thermal throttling and stuttering under heavy load.

* **🛡️ Module 13: Hardened Security Standard (Optional)**
  * Installs and configures **UFW Firewall** with strict baseline rules (deny incoming, allow outgoing) optimized for gaming.
  * Hardens authentication by reducing the **sudo timeout** to zero via a secure `/etc/sudoers.d/99-cachy-gnome-tweaks` drop-in.
  * Protects ports against hardware injection/Rubber Ducky attacks using **USBGuard** with dynamic device policy matching.
  * Activates system **AppArmor** protections and maps automatic kernel boot parameters in GRUB.
  * Bootstraps **Lynis** for automated CLI-driven standard system security auditing.
  * Installs and configures **Safing Portmaster** via AUR using your helper `yay`, enabling per-application connection monitoring, trackers blocking, and DNS-over-HTTPS (DoH).
  * Installs **ClamAV** (Linux industry standard open-source antivirus engine) with the `freshclam` auto-updater daemon active in the background for daily signature syncs with zero gaming/system performance overhead.
  * Installs **Rootkit Hunter (rkhunter)** to scan your kernel, properties, and startup routines for backdoors, rootkits, and local exploits.
  * Deploys an **Automated Weekly Scheduler (GNOME)**: Creates a background daemon checker that runs on login. If more than 7 days have passed since your last scan, it displays a premium GNOME graphical prompt (`zenity`) asking to run a complete, prioritized malware and rootkit audit in a beautiful dedicated console window.
  * Installs **Firejail & Firetools (GUI)**: Lightweight, native Linux kernel namespace sandbox. Integrates with GNOME automatically to run standard applications (browsers, Discord, Spotify) isolated in memory, and provides a beautiful dashboard to visually audit, customize, or disable sandbox policies.





---

## 🚀 Interactive Installation

Getting started is as simple as cloning the repository and running the central orchestrator:

```bash
git clone https://github.com/esfingex/cachy-tweaks.git
cd cachy-tweaks
./bin/install.sh
```


### 📦 Requirements

* **Operating System**: CachyOS or any Arch Linux base system.
* **Shell Tools**: Bash or Fish.
* **Sudo Permissions**: Necessary to register kernel parameters (`sysctl`) and configure environment files.

---

## ⌨️ Independent CLI Usage

Each module can also be called directly as an independent installer script, bypassing the interactive main GUI menu. This is highly useful for automated provisioning or selective execution:

### 🚀 Easyarch App Installer (`easyarch.sh`)
Pass the names of the tools you want to install as CLI arguments:
```bash
sudo ./scripts/easyarch.sh telegram gaming-core onlyoffice chrome github antigravity qbittorrent
```
*Available argument options:* `telegram`, `gaming`, `github`, `chrome`, `onlyoffice`, `antigravity`, `qbittorrent`.
---


## 🛠️ Project Structure

```text
cachy-tweaks/
├── LICENSE                     # MIT Open Source License
├── README.md                   # Detailed user guide & overview

├── bin/
│   └── install.sh              # Main GUM-driven selector installer
├── config/
│   └── tmux.conf               # Elegant tmux shortcuts, truecolor support & split commands
└── scripts/
    ├── nvidia.sh               # Module 1: GPU rendering & electron overrides
    ├── network.sh              # Module 2: Sysctl network & NM iwd backend selector
    ├── file-watchers.sh        # Module 3: System inotify limits expansion
    ├── snapper.sh              # Module 4: Snapper configuration & grub-btrfs daemon hook
    ├── dev-tools.sh            # Module 5: User configurations, yay bootstrapper & mise shell configs
    ├── apps-bundle.sh          # Module 6: Vivaldi, Audio stack & BT codecs
    ├── easyarch.sh             # Module 7: Telegram, Wine & Gaming Core, GitHub Desktop, Chrome, OnlyOffice, Antigravity, qBittorrent (Calls antigravity.sh)
    ├── antigravity.sh          # Standalone: Dedicated premium Antigravity IDE setup & desktop shortcut
    ├── kvm-qemu.sh             # Module 8: KVM/QEMU hypervisor & bridges setup
    ├── docker-cuda.sh          # Module 9: Docker Engine & NVIDIA container toolkit hooks
    ├── debloat.sh              # Module 10: Interactive bloatware & unused apps remover
    ├── makepkg.sh              # Module 11: makepkg compiler & RAM-disk optimizations
    ├── laptop-tuning.sh        # Module 12: ASUS tools & Intel active thermald setup
    └── security.sh             # Module 13: Hardened security standard baseline (UFW, sudo, USBGuard, AppArmor)
```

---

## 🔍 Troubleshooting & Logs

All installation runs write complete log outputs to a user-specific file for debugging:

```bash
cat /tmp/cachy-gnome-tweaks-${USER}.log
```


### 💡 Post-Installation Steps

1. **Session reload**: To activate environment variables, log out of GNOME and log back in, or run a full reboot.
2. **Developer Shells**: Start a new terminal window or run `source ~/.bashrc` (or `source ~/.config/fish/config.fish`) to load your new configurations and active shims.

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for more details.

