# CurvyRide - Sprint 1 Execution Plan

## Goal
Build a compilable project skeleton with modular boundaries, map-first home screen, planner bottom sheet shell, start point mode selection, and persisted planner defaults.

## Assumptions
- Greenfield repository (currently no source files).
- iOS target: 17+.
- Architecture: modular MVVM (`View + Model + Repository`).
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
  - `Settings`

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
      Maps+Repository.swift
      Views/
        HomeMapView.swift
        StartPointPickerView.swift
    Settings/
      Settings+View.swift
      Settings+Model.swift
      Settings+Repository.swift
      Views/
        PlannerSheetView.swift
  Tests/
    SettingsTests/
      PlannerViewModelTests.swift
      SettingsRepositoryTests.swift
    MapsTests/
      MapsModelTests.swift
```

Naming convention for feature modules:
- `Feature+View.swift`
- `Feature+Model.swift`
- `Feature+Repository.swift` (only if needed)
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
  - Keep module boundaries strict: no direct `Maps <-> Settings` imports/dependencies.
  - Cross-feature communication only via shared session(s) or notifications.

Acceptance:
- App launches successfully and reaches home map screen.

### 2.2 Map-first home screen
Implement:
- `Maps+View.swift` and `Views/HomeMapView.swift`:
  - `Map` (MapKit) full screen.
  - Planner open button (floating action).
  - Present planner bottom sheet.
- `Maps+Model.swift`:
  - UI state for planner visibility.
  - Selected start point summary placeholder.

Acceptance:
- User sees map immediately.
- Tapping planner button opens/closes sheet reliably.

### 2.3 Planner bottom sheet shell
Implement:
- `Settings+Model.swift` with fields:
  - `durationMinutes: Int` (default `60`)
  - `distanceLimitKm: Int?` (default `nil`)
  - `isLoopRoute: Bool`
  - `isFastReturn: Bool`
  - `avoidHighways: Bool`
  - `avoidTolls: Bool`
  - `isSurpriseMe: Bool`
  - `startPointMode: StartPointMode`
- `StartPointMode` enum (inside `Settings+Model.swift`):
  - `.currentLocation`
  - `.pickOnMap`
  - `.searchPlace`
- `Settings+Model.swift`:
  - Mutations for all toggles/values.
  - Load/save state via repository.
- `Settings+View.swift` and `Views/PlannerSheetView.swift`:
  - Controls for all v1 planner options (UI only).
  - Start point mode segmented control or list.

Acceptance:
- Planner options can be changed.
- Closing/reopening sheet keeps current state during app session.

### 2.4 Settings persistence
Implement:
- `Settings+Repository.swift` protocol:
  - `loadPlannerState() async -> PlannerState`
  - `savePlannerState(_ state: PlannerState) async`
- `UserDefaultsStore.swift` abstraction wrapper.
- `Data` implementation for repository encoding/decoding planner state.

Acceptance:
- Planner defaults persist between app launches.
- Default for first launch is `durationMinutes = 60`, `distanceLimitKm = nil`.

### 2.5 Start point selection shell
Implement:
- `Maps/Views/StartPointPickerView.swift` with mode selection UX.
- For Sprint 1, allow selecting mode only; map tap/search can be placeholders with clear TODOs.
- Expose selected mode in planner summary.

Acceptance:
- User can switch between `Use My Location`, `Pick on Map`, `Search Address/POI`.
- Mode persists locally.

## 3. Implementation Order

1. Create Xcode project and module targets.
2. Add `FoundationKit` + `DesignSystem` primitives.
3. Implement `Data` storage and `SettingsRepository`.
3. Implement `Data` storage and `Settings+Repository`.
4. Implement `Settings+Model` and planner state handling.
5. Implement `Maps` home screen and `Settings` planner sheet presentation.
6. Wire repository/session DI with `Factory` and keep model lifecycle in feature views.
7. Add tests.
8. Run build + tests + manual smoke check.

## 4. Concrete Task Checklist

### 4.1 Project bootstrap
- [ ] Create app target and module targets.
- [ ] Configure target dependencies and import visibility.
- [ ] Set deployment target iOS 17+.

### 4.2 Domain/UI models
- [ ] Add `Settings+Model` with `PlannerState`.
- [ ] Add `StartPointMode` in feature model file.
- [ ] Add `LoadableState` helper (if needed for async loading).

### 4.3 Repository and storage
- [ ] Add `Settings+Repository` protocol.
- [ ] Add `UserDefaultsStore`.
- [ ] Add `Data` implementation of settings repository.
- [ ] Add serialization keys and migration-safe default mapping.

### 4.4 ViewModels
- [ ] Add planner state holder in `Settings+Model` with `@Published state`.
- [ ] Add `load()` and `save()` lifecycle methods.
- [ ] Add map screen state holder in `Maps+Model`.

### 4.5 Views
- [ ] Add `Maps+View`/`HomeMapView` with full-screen map.
- [ ] Add floating planner button.
- [ ] Add `Settings+View`/`PlannerSheetView` controls.
- [ ] Add start point mode picker component.

### 4.6 DI and composition
- [ ] Register repositories/sessions with `Factory` in implementation files.
- [ ] Keep `@StateObject` model creation in each `Feature+View.swift`.
- [ ] Inject repository/session dependencies inside `Feature+Model.swift`.
- [ ] Enforce no direct cross-feature dependencies (`Maps` must not depend on `Settings`).

### 4.7 Testing
- [ ] `SettingsModelTests`:
  - default state on first launch
  - toggle mutations
  - persistence roundtrip
- [ ] `SettingsRepositoryTests`:
  - decode fallback defaults when storage empty/corrupt
  - save/load consistency
- [ ] `MapsModelTests`:
  - planner sheet open/close state behavior

## 5. Test Matrix (Sprint 1)

Unit tests:
- `SettingsModel` initializes with defaults.
- Changing `durationMinutes` updates state.
- Changing `startPointMode` is persisted and restored.
- `distanceLimitKm` handles `nil` correctly.

Manual smoke:
1. Launch app.
2. Open planner.
3. Set duration to non-default.
4. Change start point mode.
5. Close app and relaunch.
6. Verify values restored.

## 6. Definition of Done (Sprint 1)

- Project compiles cleanly on iOS 17 simulator.
- Home map screen and planner sheet are functional.
- Planner state persists across relaunch.
- Start point mode is selectable and persisted.
- Unit tests for planner state/repository pass.
- No P1 bugs in Sprint 1 scope.

## 7. Explicitly Deferred to Sprint 2+

- Real route generation.
- Scenic scoring.
- Loop/Fast Return routing behavior.
- Anti-repeat ranking.
- Google Maps export.
- Full map tap/search implementation for actual coordinates.
