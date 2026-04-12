# CurvyRide Typography Directions

## Recommended

- `SF Pro Display` for route names, screen titles, and sheet headings.
- `SF Pro Text` for form controls, chips, overlays, helper copy, and body text.
- `monospacedDigit()` for dynamic metrics by default.
- `SF Mono` only where we want a stronger instrument-panel feeling:
  - duration
  - distance
  - elevation
  - curve/scenic percentages

## Why this is the best fit

- It preserves native iOS quality.
- It lets layout, spacing, and route graphics define the brand instead of relying on a loud font choice.
- It adds subtle motorcycle/instrument energy without making the app look like a racing dashboard.

## Secondary Direction

- `New York` can work for large editorial moments:
  - onboarding hero
  - saved route feature cards
  - history highlights

Use it sparingly. Do not bring it into the planner shell or dense map UI.

## Avoid

- Full custom font stacks across the whole app at this stage.
- Decorative condensed or motorsport fonts in the core UI.
- Using mono fonts for all copy instead of only metrics.

## SwiftUI Notes

- Safer default for live values:

```swift
Text("\(duration) min")
  .monospacedDigit()
```

- Stronger metric styling:

```swift
Text("128 km")
  .font(.custom("SF Mono", size: 18))
```

Prefer `monospacedDigit()` first, and use full `SF Mono` only in places where the design really benefits from the extra character.
