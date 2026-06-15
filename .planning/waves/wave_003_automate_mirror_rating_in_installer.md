# Wave 003 — automate mirror rating in installer

## Wave Objective
Automate the execution of `cachyos-rate-mirrors` in the installer script to guarantee that pacman always downloads from the fastest and most responsive mirror repositories.

## Tasks List
- [x] Task 1: Add cachyos-rate-mirrors check and execution logic in bin/install.sh <!-- id: 0 -->

## Verification Plan
- [x] Verify 1: Run bash syntax check on bin/install.sh to ensure no syntax errors <!-- id: 1 -->

## Suggested ADRs (Optional)
### ADR: Automate CachyOS mirrorlist optimization on installer startup
* **Context**: Dead or slow mirrors on Arch/CachyOS can cause silent hangs or 404 package errors during automated script installations.
* **Decision**: Automatically execute `cachyos-rate-mirrors` at the start of the installer (right after obtaining root credentials) to dynamically optimize download routes.

