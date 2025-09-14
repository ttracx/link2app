#!/bin/bash

# Website to iOS App - Build Script
# This script helps build and run the macOS app

set -e

echo "🚀 Building Website to iOS App..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project WebsiteToiOSApp.xcodeproj -scheme WebsiteToiOSApp

# Build the project
echo "🔨 Building project..."
xcodebuild build -project WebsiteToiOSApp.xcodeproj -scheme WebsiteToiOSApp -configuration Debug

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📱 To run the app:"
    echo "   open WebsiteToiOSApp.xcodeproj"
    echo "   Then press Cmd+R to run"
    echo ""
    echo "🔧 Or run from command line:"
    echo "   xcodebuild -project WebsiteToiOSApp.xcodeproj -scheme WebsiteToiOSApp -configuration Debug -derivedDataPath ./DerivedData"
    echo ""
    echo "📋 Features included:"
    echo "   • Website analysis with WebKit"
    echo "   • AI code generation (OpenAI + Ollama)"
    echo "   • Project management"
    echo "   • iOS app export"
    echo "   • Modern SwiftUI interface"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi