# Sprint 1 UX Smoke Checklist

Purpose: fast manual UX verification for the current `Map + Planner + Pin on Map` flow.

Use this checklist after changes that touch:
- `Maps`
- `Planner`
- start-point selection
- shared `DesignSystem` components used by those flows
- interaction states, copy, labels, or transitions

Status values:
- `PASS`
- `RISK`
- `FAIL`
- `NOT VERIFIED`

## 1. First Launch And Empty State

- Map opens without broken layout or blocked interaction.
- If start point is not ready yet, the screen shows a clear loading or empty state.
- Empty state makes the next action obvious: open planner, search, pin, or use current location.

## 2. Planner Open / Close

- Planner opens from the map without disorienting jump or visual glitch.
- Closing planner returns to the map in a predictable state.
- Reopening planner keeps the latest visible planner values.

## 3. Current Location Flow

- Tapping `Current` shows loading feedback in planner.
- On success, the start point is updated and clearly visible in planner and map summary.
- On failure, the user sees a short actionable error instead of silent failure.

## 4. Search Flow

- Typing in start search feels responsive and does not conflict with the rest of the sheet.
- Selecting a completion updates the start point correctly.
- Failed search shows a clear dismissible error.

## 5. Pin On Map Flow

- Tapping `Pin` moves the user from planner to map pin mode without losing context.
- Pin mode explains what to do in one quick glance.
- `Cancel` returns to planner without losing previously selected values.
- `Use Pin` updates the start point and returns to planner predictably.

## 6. Planner Control Clarity

- Duration slider and typed value stay in sync.
- Distance cap toggle, gauge, and typed value stay in sync.
- `Fast Return` clearly communicates when it is unavailable.
- Labels stay short, consistent, and readable without sounding overly technical.

## 7. Map Summary

- Map summary reflects current planner settings.
- Chips wrap cleanly without clipping, duplicate text, or awkward line breaks.
- Summary card remains readable in empty, loading, error, and ready states.

## 8. State Continuity

- Switching between planner tabs does not reset unrelated controls.
- Returning from pin mode preserves planner context.
- Error dismissal returns the user to a sensible next step.

## 9. Visual And Interaction Polish

- Primary actions are obvious.
- Secondary actions are present but visually quieter.
- No accidental full-screen slab, blocked gestures, or dead-end state appears in the flow.
- Icon usage improves scanning and does not replace critical meaning.

## Review Output Format

When this checklist is run, summarize results in three groups:
- `Passed`
- `Risks`
- `Not verified`
