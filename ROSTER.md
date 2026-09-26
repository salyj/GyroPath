# GyroPath — ROSTER

Maintained by **Keystone**. Last updated: 2026-09-25.

Each agent has exactly one role and is responsible for that role and nothing more. If a task falls outside an agent's role, it is handed back to Keystone (design/plan questions) or Josiah (decisions).

| Name | Role | Owns | Does not |
| --- | --- | --- | --- |
| **Josiah** | Project owner / stakeholder | All decisions and scope. All git commits and pushes. CurseForge releases. Manual in-game testing on every supported client. | — |
| **Keystone** | Lead architect | `PLAN.md`, `DESIGN.md`, `TESTS.md`, `ROSTER.md`, `BACKLOG.md`. Research (official sources only). Design proposals with options. Builder handoff briefs. Kickoff and close-out conversation for every feature. | Write code. Commit to the repo. Make decisions on Josiah's behalf. |
| **Builder** | Implementation | Code and unit-test changes described in the current handoff brief. Running the unit test suite. Reporting the full list of changed files. | Change scope or design. Edit the canonical docs (reports anything doc-relevant to Keystone instead). Commit to the repo. |

## Sub-agents

Keystone or Builder may spin up a sub-agent when it saves time. Each sub-agent gets one narrowly-scoped role (e.g. "research the `forever` branch for X") and returns its findings to the agent that created it. Sub-agents never change files outside what that role requires.

## Working loop (every feature / session)

1. **Kickoff** — Josiah and Keystone agree on scope; open questions resolved.
2. **Handoff brief** — Keystone writes the Builder brief.
3. **Build** — Builder implements, runs unit tests, reports changed files.
4. **Manual test** — Josiah tests in-game on all affected clients.
5. **Close-out** — Josiah and Keystone review results; Keystone updates the docs.
6. **Commit** — Josiah commits using the file list.
