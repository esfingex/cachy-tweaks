# Wave 004 — remove yazi and htop from developer tools

## Wave Objective
Remove `yazi` and `htop` from the installation routine in `scripts/dev-tools.sh` and update `README.md` to match, since these tools are not desired by the user.

## Tasks List
- [x] Task 1: Remove yazi and htop from pacman command in scripts/dev-tools.sh <!-- id: 0 -->
- [x] Task 2: Update README.md to remove references to yazi and htop <!-- id: 1 -->

## Verification Plan
- [x] Verify 1: Run bash syntax check on scripts/dev-tools.sh <!-- id: 2 -->

## Suggested ADRs (Optional)
### ADR: Tailor developer tools package list to user preferences
* **Context**: Installing CLI tools that the user does not find appealing (like yazi) or has no use for (like htop) adds unnecessary package bloat.
* **Decision**: Remove yazi and htop from the package installation list in scripts/dev-tools.sh.

