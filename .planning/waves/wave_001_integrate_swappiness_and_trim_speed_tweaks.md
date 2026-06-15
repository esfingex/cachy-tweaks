# Wave 001 — integrate swappiness and trim speed tweaks

## Wave Objective
Integrate system responsiveness and SSD lifespan optimizations (Virtual Memory swappiness/cache pressure and automated periodic SSD TRIM) directly into `scripts/network.sh`.

## Tasks List
- [x] Task 1: Append vm.swappiness=10 and vm.vfs_cache_pressure=50 to sysctl configuration in scripts/network.sh <!-- id: 0 -->
- [x] Task 2: Add enabling and activation check for fstrim.timer at the end of scripts/network.sh <!-- id: 1 -->

## Verification Plan
- [ ] Verify 1: Run scripts/network.sh and check that vm.swappiness is set to 10 and vm.vfs_cache_pressure is set to 50 in /etc/sysctl.d/99-cachy-gnome-tweaks.conf <!-- id: 2 -->
- [ ] Verify 2: Verify that fstrim.timer is active and enabled via systemctl <!-- id: 3 -->

## Suggested ADRs (Optional)
### ADR: Consolidate sysctl VM and connection tweaks
* **Context**: Adding standalone configuration files for every sysctl optimization can pollute the `/etc/sysctl.d/` directory.
* **Decision**: Consolidate network latency, kernel security, swappiness, and cache pressure tweaks into the single `99-cachy-gnome-tweaks.conf` file managed by `scripts/network.sh`.

