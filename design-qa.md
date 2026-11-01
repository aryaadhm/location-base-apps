# Design QA

## Evidence

- Source visual truth: `C:/Users/Arya Widya Adhitama/Downloads/KUIS PRAKTIKUM - PEMROGRAMAN MOBILE.pdf`, rendered as `C:/Users/Arya Widya Adhitama/.codex/visualizations/2026/10/31/01a1900c-be04-7151-b64e-355b0958a4a0/assignment-preview.png` (1237 × 1600 px).
- Implementation captures:
  - `test/goldens/home-screen.png`
  - `test/goldens/facility-list-screen.png`
  - `test/goldens/map-screen.png`
  - `test/goldens/facility-detail-screen.png`
- Viewport and density: 393 × 852 logical pixels at device scale factor 1; each implementation capture is 393 × 852 px.
- State: light theme, Indonesian copy, Bandung-area representative content, location permission unavailable in the deterministic renderer.
- Rendering method: Flutter golden renderer with bundled Roboto and Material Icons fonts. The map capture disables network tiles for determinism; the production map uses live OpenStreetMap tiles with attribution.

## Full-view comparison

- Home preserves the source hierarchy: healthcare identity, village illustration, facility search, four pastel category cards, and bottom navigation.
- Facility list preserves the source search/filter structure, distance-ranked facility rows, category color coding, service chips, and location/radius context.
- Map preserves the source search bar, facility markers, category legend, user recenter control, and geofence circles. Live tiles are verified by the configured production widget; the golden uses a neutral surface because widget tests block HTTP.
- Detail preserves the source image region, facility identity, type, distance/address, telephone, service chips, share action, and fixed map CTA.

## Focused comparison

- Typography: Roboto is bundled at regular, medium, and bold weights. Toolbar and button styles explicitly use the family, preventing platform fallback.
- Spacing and rhythm: 18–20 px screen margins, 12–18 px component gaps, rounded 14–18 px controls, and 393 px layouts show no overflow.
- Colors: primary blue, navy text, green puskesmas, purple clinic, and gold map category match the reference direction.
- Image quality: the generated village healthcare artwork is a project asset at 1672 × 940 px and uses the reference's bright Indonesian village art direction.
- Copy: labels and actions use Indonesian terms from the assignment; unavailable source metadata is stated instead of invented.

## Comparison history

1. Initial home capture found a 13 px branding-row overflow and incomplete reference behavior because home search was absent. Added flexible branding text and a working search field.
2. Initial phone layout placed the lower category cards behind the bottom navigation. Reduced the hero region to preserve all four cards above the navigation bar.
3. Initial map capture found a 2 px marker overflow. Increased marker bounds to match the rendered icon stack.
4. Initial toolbar and fixed-button captures used the test fallback font. Added explicit Roboto inheritance and bundled font assets; revised captures render correctly.

## Findings

- No actionable P0, P1, or P2 visual findings remain at the target viewport.
- P3: live map tile appearance varies by zoom level, network response, and upstream OpenStreetMap styling.

## Validation

- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: passed, 5 tests.
- `flutter build web --no-pub --no-wasm-dry-run`: passed.
- Android Gradle packaging could not run in this execution sandbox because Java loopback pipes are blocked. Project generation, Android manifests, plugins, and location permissions are present.

final result: passed
