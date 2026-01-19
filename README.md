# ThingsToOrg

macOS app to export Things 3 data to Org-mode format.

> **Note:** This project was vibe coded with [Claude Code](https://github.com/anthropics/claude-code).

## Features

- Export all Areas, Projects, Tasks, and Tags
- Preserves hierarchy (Area → Project → Task)
- Includes dates (DEADLINE, SCHEDULED, CLOSED)
- Includes tags and notes
- Preview before export

## Requirements

- macOS 26+
- Things 3
- Xcode 26.2+ (for building)
- Swift 6.2

## Installation

1. Clone the repository
2. Open `ThingsToOrg.xcodeproj` in Xcode
3. Build and run

## Usage

1. Launch the app
2. Go to "Export" tab
3. Click "Preview Export" to see the output
4. Click "Export to File..." to save as .org file

## Limitations

- Checklists inside tasks are not accessible via AppleScript (Things 3 limitation)
- Headings inside projects are not accessible

## License

MIT - see LICENSE file
