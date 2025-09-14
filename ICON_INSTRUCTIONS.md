# Link2App - Icon Generation Instructions

Since we cannot generate actual icon files in this environment, here are the instructions for creating the app icons:

## Icon Design Specifications

The Link2App icon should represent the concept of converting websites to mobile apps. Suggested design elements:

1. **Base Design**: A mobile phone outline with a globe/web icon
2. **Colors**: Blue gradient (#007AFF to #5AC8FA) representing technology and trust
3. **Style**: Modern, minimalist, following Apple's design guidelines
4. **Symbol**: Combination of a mobile device and web/link symbols

## Required Icon Sizes for macOS

- 16x16 pixels (app-icon-16.png)
- 32x32 pixels (app-icon-32.png) 
- 64x64 pixels (app-icon-64.png)
- 128x128 pixels (app-icon-128.png)
- 256x256 pixels (app-icon-256.png)
- 512x512 pixels (app-icon-512.png)
- 1024x1024 pixels (app-icon-1024.png)

## Icon Creation Tools

- **Professional**: Adobe Illustrator, Sketch, Figma
- **Free**: GIMP, Canva, Icon8
- **AI-Generated**: Use DALL-E, Midjourney, or Stable Diffusion with the prompt:
  "Clean, modern app icon for a macOS app that converts websites to iOS apps. Blue gradient, mobile phone with globe symbol, minimalist design, Apple style"

## Installation

1. Create the icons in the required sizes
2. Name them according to the filenames listed above
3. Place them in the `Link2App/Assets.xcassets/AppIcon.appiconset/` directory
4. The Contents.json file is already configured to reference these files

## Temporary Workaround

For development and testing, the app will use system-provided icons. The actual custom icons can be added later when running the app in Xcode on a Mac.