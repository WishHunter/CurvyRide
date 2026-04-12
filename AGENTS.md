# CurvyRide Agent Notes

## UX Smoke Rule

After any code change that touches:
- `Modules/Maps`
- `Modules/Planner`
- start-point selection
- interaction states
- copy or labels
- `DesignSystem` components used by those flows

the agent should run through every item in:

`/Users/d.molkov/Documents/work/swift/CurvyRide/Docs/UX/SPRINT1_UX_SMOKE_CHECKLIST.md`

before sending the final handoff.

## Reporting Rule

For relevant UI changes, the final handoff should include a short UX smoke summary with:
- `Passed`
- `Risks`
- `Not verified`

If an item cannot be verified from the available environment, it must be reported as `Not verified`, not as `Passed`.

## Scope

This is a lightweight manual verification rule, not a replacement for automated tests.
