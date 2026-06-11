# PixelGimb

PixelGimb is a retro CRT pixel music player prototype.

The app keeps **all art assets in one folder**:

```text
assets/icons/
```

Code separates them logically:

- files starting with `record_` are treated as record/vinyl assets
- everything else is treated as UI/control icons

## Required asset filenames

Put these PNGs in `assets/icons/`:

```text
play.png
pause.png
previous.png
next.png
shuffle.png
repeat.png
settings.png
sliders.png
profile.png
spotify.png
record_empty.png
record_label.png
record_groove.png
record_spin_01.png
record_spin_02.png
record_flip_transition.png
record_swap.png
```

## Run web locally

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

## Current status

This first prototype uses mock tracks and network album art while the UI/record system is being built. Next step is Spotify OAuth + current playback state.
