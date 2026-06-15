# Wave 002 — integrate additional community tools and paccache cleanups

## Wave Objective
Integrate community-recommended CLI/GUI utilities (yazi, kitty, goverlay, micro, htop) into dev-tools installation and automate pacman cache cleaning (paccache) at the end of debloat.sh.

## Tasks List
- [x] Task 1: Expand pacman command in scripts/dev-tools.sh to include yazi, kitty, goverlay, micro, and htop <!-- id: 0 -->
- [x] Task 2: Append paccache package cache cleanups in scripts/debloat.sh <!-- id: 1 -->
- [x] Task 3: Update README.md to document the newly integrated tools and cleanup steps <!-- id: 2 -->

## Verification Plan
- [x] Verify 1: Run bash syntax check on scripts/dev-tools.sh and scripts/debloat.sh <!-- id: 3 -->

## Suggested ADRs (Optional)
### ADR: Install high-performance terminal utilities by default
* **Context**: Modern CachyOS setups benefit significantly from fast, GPU-accelerated, and Rust-based terminal tools (like kitty, yazi) and process monitoring (htop).
* **Decision**: Add yazi, kitty, goverlay, micro, and htop to the core developer package installation block in `dev-tools.sh`.

