# CurvyRide

iOS app (SwiftUI, iOS 17+) for scenic motorcycle ride planning.

## Prerequisites

- Xcode 26+
- XcodeGen (`brew install xcodegen`)

## Project setup

1. Generate Xcode project:
   `xcodegen generate`
2. Open project:
   `open CurvyRide.xcodeproj`

## Build from CLI

```sh
xcodebuild -project CurvyRide.xcodeproj \
  -scheme CurvyRideApp \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Notes

- Dependencies are managed via SPM in `project.yml` (Factory).
- Re-run `xcodegen generate` after changing `project.yml`.
