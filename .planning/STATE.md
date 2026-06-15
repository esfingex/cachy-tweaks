# STATE.md — cachy-tweaks

## Development State

*   **Active Phase**: Wave 002 — integrate additional community tools and paccache cleanups
*   **Current Milestone**: Starting wave implementation.
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

