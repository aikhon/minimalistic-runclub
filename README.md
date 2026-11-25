# Run Club Atyrau Minimal — Garmin watch face

Second Run Club Atyrau face. Built on the structure of `../runclub-garmin` (same eight devices, jungle layout, AMOLED/MIP split, generated Barlow Condensed atlases, scripts, tests), but the design trades the skyline, contours and gauges for a quiet layout carrying twice as many stats.

[Forerunner 265 preview](docs/previews/fr265-active.png)

## Layout

Dashboard grid split by thin graphite lines, inspired by a reference mock-up:

| Zone | Content |
| --- | --- |
| Bezel | Ticks every 30°, lime at 12/3/6/9 |
| Top | Date block (`WED` / lime `25` + `NOV` / year) beside the white club logo |
| Middle | Large `HH:MM`, grey seconds, lime AM/PM in 12-hour mode |
| Right column | Heart rate · calories · temperature, with lime icons |
| Bottom row | Distance · steps · battery |
| Footer | Weekly intensity minutes `WEEK 85/150 MIN` |

Palette is the club's: black, lime `#CCFF00`, white `#F4F4F4`, secondary `#BEBEBE`, graphite for lines. Layout fractions live in `source/DesignTokens.mc`. Battery fill turns white at 15% or below.

## Data

- Steps, distance, calories and weekly intensity minutes (+ goals) from `ActivityMonitor`; goals fall back to 10,000 steps / 150 min.
- Heart rate: newest positive sample within 5 min.
- Temperature: current conditions from the phone-synced forecast (`Toybox.Weather`), shown in °C or °F per the watch setting; `--` before the first sync.
- Seconds are visible only while the display is active.
- Refreshed once per minute; no sensors enabled, nothing stored, no network.

## Sleep

Identical to the first face: AMOLED shows clock/date/logo in four rotating bands; MIP keeps the large clock.

## Build and test

The scripts use `.tools/connectiq-sdk` and `.secrets/developer_key.der` here if present, otherwise fall back to the sibling `../runclub-garmin` copies (same developer key, separate app UUID).

```powershell
.\scripts\Generate-DesignResources.ps1   # regenerate font atlases and icons
.\scripts\Build.ps1 [-Release] [-Device fr265]
.\scripts\Build.ps1 -Device fr265 -TestBuild
.\scripts\Simulate.ps1 -Device fr265 [-Tests]
.\scripts\Check-Resources.ps1
```

Outputs are `bin/rcmin-<device>[-release|-tests].prg`. Install by copying the matching release PRG to `GARMIN/APPS`.

## Status

- All 8 targets build without warnings; 4 unit-test suites pass on fr265.
- Visually checked on fr265, fr255 and fr55. On fr55 and fr255sm the small labels are very small. Sleep mode and physical watches still need checking.
