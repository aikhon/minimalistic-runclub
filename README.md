# Run Club Atyrau Minimal — Garmin watch face

Second Run Club Atyrau face. Built on the structure of `../runclub-garmin` (same eight devices, jungle layout, AMOLED/MIP split, generated Barlow Condensed atlases, scripts, tests), but the design trades the skyline, contours and gauges for a quiet layout carrying twice as many stats.

[Forerunner 265 preview](docs/previews/fr265-active.png)

## Layout

| Zone | Content |
| --- | --- |
| Top | Small lime club logo (EST masked) |
| Date | `WED` lime + `04 NOV` white |
| Clock | Hours white, minutes lime, Barlow ExtraBold; follows 12/24h |
| Grid row 1 | STEPS · KM · BPM |
| Grid row 2 | KCAL · BODY (Body Battery) · STRESS |
| Footer | Weekly intensity minutes `85/150 MIN` (+ AM/PM), battery bar + % |
| Bezel left | Daily step-goal ring, fills bottom→top |
| Bezel right | Weekly intensity-minutes ring, fills bottom→top |

Palette is the club's: black, lime `#CCFF00`, white `#F4F4F4`, secondary `#BEBEBE`, graphite for tracks. Layout fractions live in `source/DesignTokens.mc`. Battery bar turns white at ≤15%.

## Data

- Steps, distance, calories, floors, intensity minutes (+ goals) from `ActivityMonitor`; goals fall back to 10,000 steps / 150 min.
- Heart rate: newest positive sample within 5 min. Body Battery and stress: newest `SensorHistory` sample, guarded with `has` checks — devices without them show `--`.
- Refreshed once per minute; no sensors enabled, nothing stored, no network.

## Sleep

Identical to the first face: AMOLED shows clock/date/logo in four rotating bands; MIP keeps the large clock.

## Build and test

The scripts use `.tools/connectiq-sdk` and `.secrets/developer_key.der` here if present, otherwise fall back to the sibling `../runclub-garmin` copies (same developer key, separate app UUID).

```powershell
.\scripts\Generate-DesignResources.ps1   # regenerate font atlases
.\scripts\Build.ps1 [-Release] [-Device fr265]
.\scripts\Build.ps1 -Device fr265 -TestBuild
.\scripts\Simulate.ps1 -Device fr265 [-Tests]
.\scripts\Check-Resources.ps1
```

Outputs are `bin/rcmin-<device>[-release|-tests].prg`. Install by copying the matching release PRG to `GARMIN/APPS`.

## Status

- All 8 targets build without warnings; 4 unit-test suites pass on fr265.
- Visually checked on fr265 only. Other sizes, sleep mode and physical watches still need checking.
