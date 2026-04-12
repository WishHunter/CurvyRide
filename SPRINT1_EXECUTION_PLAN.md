# CurvyRide - Sprint 1 Execution Plan

## Goal
Build a compilable project skeleton with modular boundaries, map-first home screen, planner bottom sheet shell, start point selection shell, and persisted planner defaults.

## Assumptions
- Greenfield repository (currently no source files).
- iOS target: 17+.
- Architecture: modular MVVM (`View + Model + Session/Store`).
- Sprint 1 ships scaffolding and basic flow, not full routing logic.

## 1. Module and Project Setup

### 1.1 Create workspace/project structure
Create:
- `CurvyRide.xcodeproj`
- `CurvyRideApp` (app target)
- Module groups/targets:
  - `AppCore`
  - `DesignSystem`
  - `FoundationKit`
  - `Data`
  - `Maps`
  - `Planner`

### 1.2 Suggested folder tree
```text
CurvyRide/
  App/
    CurvyRideApp.swift
    RootView.swift
  Modules/
    AppCore/
      DI/
        DI_GUIDELINES.md
      Navigation/
        AppRouter.swift
    DesignSystem/
      Theme/
        ColorTokens.swift
        SpacingTokens.swift
      Components/
        PrimaryButton.swift
        BottomSheetContainer.swift
    FoundationKit/
      Logging/
        Logger.swift
      Common/
        LoadableState.swift
    Data/
      Sessions/
        PlannerSession.swift
      Storage/
        UserDefaultsStore.swift
    Maps/
      Maps+View.swift
      Maps+Model.swift
      Views/
        HomeMapView.swift
        StartPointPickerView.swift
    Planner/
      Planner+View.swift
      Planner+Model.swift
  Tests/
    PlannerTests/
      PlannerViewModelTests.swift
    MapsTests/
      MapsModelTests.swift
```

Naming convention for feature modules:
- `Feature+View.swift`
- `Feature+Model.swift`
- `Views/` for helper/supporting views

## 2. Sprint 1 Scope by Deliverable

### 2.1 App shell and DI
Implement:
- `CurvyRideApp.swift`: app entry point, render `RootView`.
- `RootView.swift`: render `Maps+View` (feature root screen).
- DI approach for Sprint 1:
  - Use `Factory` for `Repository` and `Data/Sessions` only.
  - Register each `Factory` container in the same file as its implementation.
  - Feature models are not created in app root/container.
  - `Feature+View.swift` owns `@StateObject` model lifecycle.
  - `Feature+Model.swift` injects dependencies via `@Injected`/`@LazyInjected`.
  - Keep module boundaries strict: no direct `Maps <-> Planner` imports/dependencies.
  - Cross-feature communication only via shared session(s) or notifications.

Acceptance:
- App launches successfully and reaches home map screen.

### 2.2 Map-first home screen
Implement:
- `Maps+View.swift`:
  - `Map` (MapKit) full screen.
  - Planner open button (floating action).
  - Present planner bottom sheet using `Planner+View.swift`.
- `Maps+Model.swift`:
  - Observe `PlannerSession.settings` and expose map-facing summary state.

Acceptance:
- User sees map immediately.
- Tapping planner button opens/closes sheet reliably.

### 2.3 Planner bottom sheet shell
Implement:
- `Planner+Model.swift` with fields:
  - `durationMinutes: Int` (default `60`)
  - `distanceLimitKm: Int?` (default `nil`)
  - `isLoopRoute: Bool`
  - `isFastReturn: Bool`
  - `avoidHighways: Bool`
  - `avoidTolls: Bool`
  - `startPoint: PlannerStartPoint?`
- `PlannerStartPoint` model:
  - `latitude: Double`
  - `longitude: Double`
  - `displayName: String?`
- `Planner+Model.swift`:
  - Mutations for all toggles/values.
  - Validate/normalize incoming values.
  - Write validated settings into `PlannerSession.settings`.
- `Planner+View.swift`:
  - Controls for all v1 planner options (UI only).
  - Start point controls: search field, `My current location`, `Show on map`.
  - `Show on map` closes planner sheet, enters map selection mode, and returns back to planner after `Apply`.

Acceptance:
- Planner options can be changed.
- Closing/reopening sheet keeps current state via `PlannerSession`.

### 2.4 UX/UI baseline and interaction states
Implement:
- UX/UI baseline artifacts for implemented Sprint 1 screens (`HomeMapScreen`, `PlannerBottomSheet`):
  - Screen state definitions for `loading`, `empty`, `error`, and normal/interactive state.
  - Interaction behavior spec for planner open/close, start point picker transitions, and `Show on map -> Apply -> return`.
  - Copy and labels alignment for planner controls (`Start From`, duration, toggles).
- `DesignSystem` baseline additions:
  - Minimal color/spacing/typography tokens used by `Maps` and `Planner`.
  - Shared UI primitives for primary button and bottom sheet action rows.
- UX smoke checklist for implemented flow:
  - First-launch clarity.
  - State continuity when reopening planner.
  - Predictable transitions between map and planner.

Acceptance:
- Implemented Sprint 1 screens use a consistent baseline (tokens, labels, and interaction states).
- Required `loading/empty/error` states are explicitly defined for current screens, even if some are placeholder in Sprint 1.

### 2.5 Planner persistence
Implement:
- `UserDefaultsStore.swift` abstraction wrapper.
- `PlannerSession.swift` owns load/save of `PlannerSettings` via `UserDefaultsStore`.
- `Planner+Model.swift` does not talk to storage directly; it only validates and updates session state.
- Data encoding/decoding for planner settings with migration-safe default mapping.

Acceptance:
- Planner defaults persist between app launches.
- Default for first launch is `durationMinutes = 60`, `distanceLimitKm = nil`.

### 2.6 Start point selection shell
Implement:
- Planner start point UX:
  - Search address/POI from planner sheet.
  - Use current location from planner sheet.
  - Pick by moving map under a fixed center pin and pressing `Apply`.
- Expose selected start point in planner and map summary.

Acceptance:
- User can set start point via current location, map pick, or search.
- Selected start point is reflected in planner and map summary during app session.

## 3. Implementation Order

1. Create Xcode project and module targets.
2. Add `FoundationKit` + `DesignSystem` primitives.
3. Implement `Planner+Model` and planner settings handling.
4. Define and align UX/UI baseline for implemented Sprint 1 flows (`HomeMapScreen` + `PlannerBottomSheet`).
5. Implement `PlannerSession` as runtime source of truth for planner settings.
6. Implement `Maps` home screen and `Planner` planner sheet presentation.
7. Keep model lifecycle in feature views.
8. Wire `MapsModel`/`PlannerModel` to shared `PlannerSession`.
9. Add tests.
10. Run build + tests + manual smoke check.

## 4. Concrete Task Checklist

### 4.1 Project bootstrap
- [x] Create app target and module targets.
- [x] Configure target dependencies and import visibility.
- [x] Set deployment target iOS 17+.

### 4.2 Domain/UI models
- [x] Add `Planner+Model` with `PlannerSettings`.
- [x] Add `PlannerStartPoint` in session/model layer.
- [ ] Add `LoadableState` helper (if needed for async loading).

### 4.3 Repository and storage
- [ ] Add `UserDefaultsStore`.
- [ ] Add planner settings serialization keys and migration-safe default mapping.
- [ ] Wire `PlannerSession` to load/save settings via store.

### 4.4 ViewModels
- [x] Add planner state holder in `Planner+Model` with `@Published state`.
- [x] Add validation/normalization logic in `Planner+Model` before writing into session.
- [x] Add map screen state holder in `Maps+Model` derived from `PlannerSession`.

### 4.5 Views
- [x] Add `Maps+View` with full-screen map.
- [x] Add floating planner button.
- [x] Add `Planner+View` controls.
- [x] Add start point selection flow (`My current location`, `Show on map`, search).

### 4.6 DI and composition
- [x] Keep `@StateObject` model creation in each `Feature+View.swift`.
- [x] Register and inject shared `PlannerSession` via `Factory`.
- [x] Enforce no direct cross-feature dependencies (`Maps` must not depend on `Planner`).

### 4.7 Testing
- [ ] `PlannerModelTests`:
  - default state on first launch
  - toggle mutations with validation
  - writes validated values into session
- [ ] `PlannerSessionTests`:
  - persistence roundtrip via store
  - fallback defaults when storage is empty/corrupt
- [ ] `MapsModelTests`:
  - reacts to `PlannerSession.settings` updates

### 4.8 UX/UI
- [x] Define `loading/empty/error` states for `HomeMapScreen` and `PlannerBottomSheet`.
- [x] Align planner labels and control copy (`Start From`, duration/toggles naming).
- [x] Add minimal shared tokens/components in `DesignSystem` used by implemented screens.
- [x] Add UX smoke checklist for planner open/close and map-selection return flow.

## 5. Test Matrix (Sprint 1)

Unit tests:
- `PlannerModel` validates and writes changes into session.
- Changing `durationMinutes` updates `PlannerSession.settings`.
- Changing start point updates `PlannerSession.settings.startPoint`.
- `distanceLimitKm` handles `nil` correctly.

Manual smoke:
1. Launch app.
2. Open planner.
3. Set duration to non-default.
4. Set start point via search or `My current location` or `Show on map`.
5. Close app and relaunch.
6. Verify values restored.

## 6. Definition of Done (Sprint 1)

- Project compiles cleanly on iOS 17 simulator.
- Home map screen and planner sheet are functional.
- UX/UI baseline for implemented Sprint 1 screens is defined and applied (tokens, labels, interaction states).
- Planner state persists across relaunch.
- Start point is selectable and persisted.
- Unit tests for planner model/session pass.
- No P1 bugs in Sprint 1 scope.

## 7. Explicitly Deferred to Sprint 2+

- Real route generation.
- Scenic scoring.
- Loop/Fast Return routing behavior.
- Anti-repeat ranking.
- Google Maps export.
- Full map tap/search implementation for actual coordinates.
