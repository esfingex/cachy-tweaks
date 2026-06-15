# STATE.md — cachy-tweaks

## Development State

*   **Active Phase**: Wave 005 — remove goverlay from developer tools
*   **Current Milestone**: Wave completed successfully.
*   **Git Position**: [Active branch or commit hash]

---

## Architectural Decision Records (ADR)

### 1. [Decision Title]
*   **Date**: [YYYY-MM-DD]
*   **Context**: [What problem or context prompted this decision]
*   **Decision**: [Details of the technical decision made]
*   **Justification**: [Why this is the best solution and what alternatives were discarded]

---

## Active Blockers
*   None.


### ADR: Consolidate sysctl VM and connection tweaks
*   **Date**: 2026-06-15
*   **Context**: Adding standalone configuration files for every sysctl optimization can pollute the `/etc/sysctl.d/` directory.
*   **Decision**: Consolidate network latency, kernel security, swappiness, and cache pressure tweaks into the single `99-cachy-gnome-tweaks.conf` file managed by `scripts/network.sh`.



### ADR: Install high-performance terminal utilities by default
*   **Date**: 2026-06-15
*   **Context**: Modern CachyOS setups benefit significantly from fast, GPU-accelerated, and Rust-based terminal tools (like kitty, yazi) and process monitoring (htop).
*   **Decision**: Add yazi, kitty, goverlay, micro, and htop to the core developer package installation block in `dev-tools.sh`.



### ADR: Automate CachyOS mirrorlist optimization on installer startup
*   **Date**: 2026-06-15
*   **Context**: Dead or slow mirrors on Arch/CachyOS can cause silent hangs or 404 package errors during automated script installations.
*   **Decision**: Automatically execute `cachyos-rate-mirrors` at the start of the installer (right after obtaining root credentials) to dynamically optimize download routes.



### ADR: Tailor developer tools package list to user preferences
*   **Date**: 2026-06-15
*   **Context**: Installing CLI tools that the user does not find appealing (like yazi) or has no use for (like htop) adds unnecessary package bloat.
*   **Decision**: Remove yazi and htop from the package installation list in scripts/dev-tools.sh.



### ADR: Avoid game-platform dependent overlay utilities in system tools
*   **Date**: 2026-06-15
*   **Context**: GOverlay relies heavily on Steam setups and libraries. For users playing independent/standalone or non-Steam game builds, this introduces unwanted dependencies.
*   **Decision**: Remove goverlay from the package installation list in scripts/dev-tools.sh.

