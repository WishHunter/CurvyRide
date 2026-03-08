# CurvyRide - PRD, Technical Strategy, Sprint Backlog

## 1. Product Overview

### 1.1 Product vision
CurvyRide is an iOS app for motorcyclists who want scenic asphalt rides with more turns and less highway/city monotony, including quick evening rides and loop trips.

### 1.2 Target users
- Beginner riders (road only, no off-road/enduro).
- Experienced riders who want varied, twisty routes.
- Region for v1: Serbia + Europe.
- App language in v1: English only.

### 1.3 Core user jobs
- Plan a 60-minute ride for the evening.
- Get 3-4 scenic alternatives with fewer straight/highway segments.
- Start from current location or a custom start point (meeting point).
- Ride a loop and optionally return faster using a simpler route profile.

## 2. Scope

### 2.1 MVP (v1.0) in scope
- iOS 17+ app in SwiftUI.
- Modular MVVM architecture (`View + Model + Repository`).
- Apple MapKit visualization.
- Route planner in BottomSheet over map.
- Configurable route generation:
  - Default duration: 60 min.
  - Distance cap: none by default.
  - Loop route toggle.
  - Avoid highways toggle.
  - Avoid toll roads toggle.
  - Fast Return toggle (clear naming in UI).
  - Surprise Me mode (fully random route from selected start point).
- Start point selection:
  - Current location.
  - Pick on map.
  - Search address/POI.
- Generate and display 3-4 alternative routes.
- Local route history + anti-repeat preference.
- Save selected routes locally.
- Export/open route in Google Maps via deep link.
- Unit tests for core domain logic.

### 2.2 Out of scope (post-MVP)
- Offline routing.
- Mid-route manual waypoint editing.
- Account/auth/sync across devices.
- Advertising/subscription.
- Multi-map export integrations beyond Google Maps.
- Enduro/off-road route profiles.

## 3. Functional Requirements

### 3.1 Route planning inputs
- Start point (required): current GPS or manually selected point.
- Duration target (required; default 60 min).
- Toggles:
  - Loop route.
  - Fast Return.
  - Avoid highways.
  - Avoid toll roads.
  - Surprise Me.

### 3.2 Route generation behavior
- Hard exclusions in v1:
  - Ferries.
  - Unpaved roads.
- Prefer asphalt roads with good riding flow.
- Generate candidate routes and return top 3-4 ranked options.
- If Loop route is on:
  - Route should end near start point.
- If Fast Return is on:
  - Return segment can prioritize ETA over scenic quality.

### 3.3 Route scoring and ranking (v1 heuristic)
`score = w_surface + w_time + w_curvature + w_elevation + w_traffic - penalties`

Priority order (as specified):
1. Surface quality/asphalt compliance.
2. Time fit (close to desired duration).
3. Curviness (higher turn density).
4. Elevation gain/variation.
5. Traffic conditions.

Penalties:
- Highway usage (depending on toggle).
- Toll usage (depending on toggle).
- Urban density segments.
- Similarity to recently used/saved routes (anti-repeat).

### 3.4 Route preview card fields
- Estimated duration.
- Distance.
- Elevation gain.
- Turn percentage.
- Scenic score.

### 3.5 History and anti-repeat
- Persist selected and completed routes locally.
- Store route geometry fingerprints/hash.
- Penalize highly similar routes during ranking to increase variety over days.

### 3.6 External navigation handoff
- Open selected route in Google Maps via deep link.
- No persistent default app selection in v1.

## 4. Non-Functional Requirements

- Platform: iOS 17+.
- Stability first (crash-free and predictable route generation).
- Route variety as explicit quality target.
- Responsive UX:
  - Planner interactions should feel immediate.
  - Alternative generation should be bounded and cancellable.
- Privacy-first local mode:
  - No account required.
  - No server dependency in MVP.

## 5. UX Strategy

### 5.1 Main flow
1. User opens map-first home screen.
2. Taps planner button -> BottomSheet opens.
3. Selects start point + options.
4. Taps Generate.
5. Sees 3-4 routes on map and in list cards.
6. Selects one route.
7. Starts in-app preview or exports to Google Maps.

### 5.2 Core screens (v1)
- HomeMapScreen (map-first).
- PlannerBottomSheet.
- StartPointPicker (map tap + search).
- RouteAlternativesList.
- RouteDetailsCard.
- RideHistoryScreen.
- SettingsScreen.

### 5.3 UX copy (key terms)
- `Fast Return` (clearer than aggressive alternatives).
- `Surprise Me`.
- `Start From`.
- `Loop Ride`.

## 6. Technical Strategy

### 6.1 Proposed module structure
- `AppCore`
  - App entry/root composition, app routing, feature flags.
- `DesignSystem`
  - Shared UI components, spacing/typography tokens, BottomSheet primitives.
- `FoundationKit`
  - Cross-cutting utilities, logging, errors, concurrency helpers.
- `Data`
  - Repositories + local persistence adapters + shared sessions.
- `RoutingDomain`
  - Route request models, candidate generation, scenic scoring, anti-repeat ranking.
- Feature UI modules (use one consistent file convention per feature):
  - `Maps`
    - `Maps+View.swift`
    - `Maps+Model.swift`
    - `Maps+Repository.swift` (if needed)
    - `Views/` (supporting views, if needed)
  - `Planner`
    - `Planner+View.swift`
    - `Planner+Model.swift`
    - `Planner+Repository.swift` (if needed)
    - `Views/` (supporting views, if needed)
  - `RideHistory`
    - `RideHistory+View.swift`
    - `RideHistory+Model.swift`
    - `RideHistory+Repository.swift` (if needed)
    - `Views/` (supporting views, if needed)
  - `Export`
    - `Export+View.swift` (if needed)
    - `Export+Model.swift`
    - `Export+Repository.swift`
    - `Views/` (supporting views, if needed)

### 6.2 MVVM boundaries
- `View`: SwiftUI screens/components. `Feature+View.swift` is the feature root and owns `@StateObject` model lifecycle.
- `Model`: feature logic + UI state (`@Published`), dependencies injected via `@Injected`/`@LazyInjected`.
- `Repository`: data access abstraction (local storage and map/routing provider adapters), consumed only by models.
- DI scope: use `Factory` for repositories and shared sessions; do not register feature models in DI.
- Registration rule: declare `Factory` registration in the same file as concrete implementation.
- Module boundary rule: no direct cross-feature dependencies (e.g., `Maps` must not depend on `Planner`).
- Cross-feature communication: only through shared `Data/Sessions` or notifications.

### 6.3 Protocol-first provider abstraction
Define replaceable contracts to avoid lock-in:
- `RoutingProviderProtocol`
- `TrafficProviderProtocol`
- `ElevationProviderProtocol`
- `NavigationExportProtocol`

v1 implementations can be minimal and MapKit-centered, but interfaces must be future-proof for provider swaps.

### 6.4 Persistence approach (local only)
- Storage: Core Data or SQLite-backed lightweight store (implementation choice).
- Persist:
  - User settings.
  - Saved routes.
  - Recent generated routes/fingerprints.
  - Last used custom start point.

### 6.5 Concurrency
- Use Swift concurrency (`async/await`) for route generation and ranking pipeline.
- Cancellation support when user changes planner inputs quickly.

## 7. Data Model (v1 draft)

- `RoutePlanRequest`
  - `startPoint`
  - `durationTargetMin`
  - `isLoop`
  - `isFastReturn`
  - `avoidHighways`
  - `avoidTolls`
  - `isSurpriseMe`
- `RouteCandidate`
  - `polyline`
  - `eta`
  - `distance`
  - `elevationGain`
  - `turnPercentage`
  - `scenicScore`
  - `metadata` (surface flags, toll/highway flags)
- `SavedRoute`
  - `id`
  - `createdAt`
  - `routeFingerprint`
  - `selectedOptions`
- `UserSettings`
  - planner defaults
  - last start point mode

## 8. Definition of Done (Global)

- Feature behavior matches PRD acceptance criteria.
- Unit tests added/updated for domain logic.
- No critical crashes in tested flows.
- Basic telemetry/logging for failures available locally (debug logs).
- Code follows module boundaries and protocol abstractions.

## 9. Sprint Backlog and DoD

## Sprint 1 - Foundation and Planner Shell
Goal: Build app skeleton, module wiring, and core planner UX shell.

Backlog:
- Create module structure and dependency graph.
- Implement HomeMapScreen with MapKit baseline.
- Implement PlannerBottomSheet with options/state.
- Implement start point modes UI (current/manual placeholder wiring).
- Add Planner persistence for planner defaults (duration=60).

DoD:
- App runs with map-first home + functional planner sheet.
- Planner state persists locally between launches.
- Start point mode selectable in UI.
- Unit tests for planner state reducer/view model.

## Sprint 2 - Routing Engine v1 and Alternatives
Goal: Generate and render 3-4 scenic alternatives.

Backlog:
- Define domain models (`RoutePlanRequest`, `RouteCandidate`).
- Implement candidate generation pipeline.
- Implement scenic scoring heuristic and ranking.
- Add hard exclusions (unpaved/ferries where data available).
- Render alternatives on map + list cards.

DoD:
- User gets 3-4 route alternatives for valid input.
- Cards show duration, distance, elevation gain, turn percentage, scenic score.
- Ranking follows specified priority order.
- Unit tests for scoring and ranking logic.

## Sprint 3 - Loop, Fast Return, Surprise Me, Anti-repeat
Goal: Ship core differentiation behavior.

Backlog:
- Implement loop route generation constraints.
- Implement Fast Return option for return segment profile.
- Implement Surprise Me generation path.
- Add route fingerprinting and similarity penalty.
- Save selected routes and recent generated routes.

DoD:
- Loop routes end near start (within defined radius threshold).
- Fast Return changes routing behavior in measurable way (ETA bias).
- Surprise Me produces valid route without extra user tuning.
- Repeated route suggestions are visibly reduced over time.
- Unit tests for similarity penalty and mode toggles.

## Sprint 4 - Google Maps Export and History
Goal: Complete v1 practical riding flow.

Backlog:
- Implement Google Maps deep link export service.
- Add route handoff from route details/action buttons.
- Build RideHistory screen with saved routes list.
- Enable reopening saved routes on map.

DoD:
- Selected route opens in Google Maps successfully.
- Saved routes appear in history and can be reopened.
- Export and history flows covered by integration-style unit tests (where feasible).

## Sprint 5 - Stabilization and Release Readiness
Goal: Harden quality for first beta.

Backlog:
- Crash and edge-case hardening for route generation.
- Improve loading/error states and retry UX.
- Performance tuning and cancellation correctness.
- Final QA checklist and release notes draft.

DoD:
- No open P0/P1 defects.
- Route generation handles invalid/unavailable data gracefully.
- Core journeys pass smoke test matrix.
- v1 scope freeze documented.

## 10. Risks and Mitigations

- Road data quality inconsistency across regions.
  - Mitigation: fallback scoring, conservative filters, explicit uncertainty handling.
- Routing provider limitations for strict scenic constraints.
  - Mitigation: candidate generation + post-ranking instead of single-pass routing.
- Repetition despite anti-repeat.
  - Mitigation: fingerprint similarity threshold tuning and recency weighting.
- UX overload in planner.
  - Mitigation: strong defaults, concise labels, advanced options progressively disclosed.

## 11. Open Decisions (to lock before implementation)

- Final label choice: `Fast Return` vs `Quick Way Back`.
- Storage tech in `Data` module: Core Data vs SQLite abstraction.
- Exact thresholds:
  - Loop completion radius.
  - Similarity cutoff for anti-repeat.
  - Turn percentage calculation method.

## 12. v1 Success Criteria

- Users can generate and start a scenic route in under 30 seconds.
- At least one acceptable route in most planner runs.
- Subjective user feedback confirms route variety improvement over default commuting paths.
- Stable beta behavior on iOS 17+ devices.
