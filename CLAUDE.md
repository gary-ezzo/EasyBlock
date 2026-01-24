# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EasyBlock is a native iOS application built with SwiftUI targeting iOS 17.5+. It supports both iPhone and iPad devices.

## Build Commands

Build and run using Xcode or via command line:

```bash
# Debug build
xcodebuild -scheme EasyBlock -configuration Debug

# Release build
xcodebuild -scheme EasyBlock -configuration Release

# Archive for distribution
xcodebuild -scheme EasyBlock -archivePath build/EasyBlock.xcarchive archive
```

## Architecture

- **EasyBlockApp.swift**: App entry point using `@main`, creates the main `WindowGroup` scene
- **ContentView.swift**: Primary UI view
- **Assets.xcassets/**: App icon, colors, and image assets

The project uses pure SwiftUI with no external dependencies. All UI follows Apple's declarative SwiftUI patterns.

## Development Notes

- Bundle Identifier: `garyezzo.EasyBlock`
- Automatic code signing configured for development
- SwiftUI previews enabled for rapid iteration
- No test target currently configured
