# Wave 005 — remove goverlay from developer tools

## Wave Objective
Remove `goverlay` from the installation routine in `scripts/dev-tools.sh` and update `README.md` to match, since this tool requires Steam integrations and does not align with the user's setup.

## Tasks List
- [x] Task 1: Remove goverlay from pacman command in scripts/dev-tools.sh <!-- id: 0 -->
- [x] Task 2: Update README.md to remove references to goverlay <!-- id: 1 -->

## Verification Plan
- [x] Verify 1: Run bash syntax check on scripts/dev-tools.sh <!-- id: 2 -->

## Suggested ADRs (Optional)
### ADR: Avoid game-platform dependent overlay utilities in system tools
* **Context**: GOverlay relies heavily on Steam setups and libraries. For users playing independent/standalone or non-Steam game builds, this introduces unwanted dependencies.
* **Decision**: Remove goverlay from the package installation list in scripts/dev-tools.sh.

