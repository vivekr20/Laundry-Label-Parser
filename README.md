# Laundry Label Scanner

An iPhone app that scans a clothing item's care label and instantly tells you how to wash and dry it correctly.

## Features

- 📷 **Live camera scanning** — point your camera at a care label and tap the shutter button
- 🖼️ **Photo library support** — choose an existing photo from your camera roll
- 🔍 **Vision OCR** — uses Apple's on-device Vision framework to read label text (no internet required)
- 🧺 **Full care instruction parsing** — washing temperature, drying method, bleaching, ironing and dry-cleaning
- 🎨 **Clear results UI** — colour-coded cards (blue = allowed, orange = caution, red = prohibited)

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 15.0+ |
| iOS Deployment Target | 16.0+ |
| Swift | 5.9+ |

## Getting Started

### Open in Xcode

```bash
git clone https://github.com/vivekr20/Laundry-Label-Parser.git
open LaundryLabelParser.xcodeproj
```

Select a simulator or connected device (iOS 16+) and press **⌘R** to build and run.

> **Note:** Camera scanning requires a physical device. The photo-library picker works in the simulator.

### Regenerate the Xcode project (optional)

If you prefer to manage the project with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
```

## Project Structure

```
LaundryLabelParser/
├── App/
│   └── LaundryLabelParserApp.swift   # @main entry point
├── Views/
│   ├── ContentView.swift             # Home screen with Scan / Choose buttons
│   ├── CameraView.swift              # AVFoundation live-camera capture
│   ├── ImagePickerView.swift         # PHPickerViewController wrapper
│   └── ScanResultView.swift          # Care-instruction cards
├── ViewModels/
│   └── ScanViewModel.swift           # Bridges UI → LabelAnalyzerService
├── Services/
│   └── LabelAnalyzerService.swift    # Vision OCR + text parser
├── Models/
│   ├── CareInstruction.swift         # WashInstruction, DryInstruction, …
│   └── LaundryLabel.swift            # Aggregated label model
├── Assets.xcassets/
└── Info.plist

LaundryLabelParserTests/
└── LabelParserTests.swift            # Unit tests for the text parser

LaundryLabelParser.xcodeproj/
project.yml                           # XcodeGen configuration
```

## How It Works

1. The user points the camera at a garment care label and presses the shutter.
2. `LabelAnalyzerService` runs a `VNRecognizeTextRequest` on the captured image.
3. The recognised text lines are lower-cased and matched against keyword patterns for each care category (washing, drying, bleaching, ironing, dry-cleaning).
4. The resulting `LaundryLabel` model is displayed as a set of colour-coded `CareCard` views.

## Running the Tests

The label-parsing logic is fully unit-tested and runs without a device:

```bash
xcodebuild test \
  -project LaundryLabelParser.xcodeproj \
  -scheme LaundryLabelParser \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or simply press **⌘U** inside Xcode.

## Privacy

All image processing is performed **on-device** using Apple's Vision framework. No photos or label data are sent to any server.

## License

[GNU General Public License v3.0](LICENSE)
