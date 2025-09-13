#!/bin/bash

# Link2App Setup Verification Script
# This script helps verify that your development environment is ready for Link2App

echo "🔗 Link2App Setup Verification"
echo "=============================="
echo ""

# Check macOS version
echo "1. Checking macOS version..."
os_version=$(sw_vers -productVersion)
echo "   macOS version: $os_version"

if [[ $(echo "$os_version >= 14.0" | bc -l) -eq 1 ]]; then
    echo "   ✅ macOS 14.0+ required: PASSED"
else
    echo "   ❌ macOS 14.0+ required: FAILED"
    echo "   Please upgrade to macOS 14.0 or later"
fi
echo ""

# Check Xcode installation
echo "2. Checking Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    xcode_version=$(xcodebuild -version | head -n 1)
    echo "   $xcode_version"
    echo "   ✅ Xcode installed: PASSED"
else
    echo "   ❌ Xcode not found: FAILED"
    echo "   Please install Xcode from the Mac App Store"
fi
echo ""

# Check Swift version
echo "3. Checking Swift version..."
if command -v swift &> /dev/null; then
    swift_version=$(swift --version | head -n 1)
    echo "   $swift_version"
    echo "   ✅ Swift available: PASSED"
else
    echo "   ❌ Swift not found: FAILED"
fi
echo ""

# Check if running on Apple Silicon
echo "4. Checking processor architecture..."
arch=$(uname -m)
echo "   Architecture: $arch"

if [[ "$arch" == "arm64" ]]; then
    echo "   ✅ Apple Silicon detected: OPTIMAL"
else
    echo "   ⚠️  Intel Mac detected: COMPATIBLE (but Apple Silicon recommended)"
fi
echo ""

# Check project structure
echo "5. Checking Link2App project structure..."
if [[ -d "Link2App.xcodeproj" ]]; then
    echo "   ✅ Xcode project found: PASSED"
else
    echo "   ❌ Xcode project not found: FAILED"
    echo "   Make sure you're running this script from the Link2App directory"
fi

if [[ -f "Link2App/Link2AppApp.swift" ]]; then
    echo "   ✅ Main app file found: PASSED"
else
    echo "   ❌ Main app file not found: FAILED"
fi

if [[ -f "Link2App/ContentView.swift" ]]; then
    echo "   ✅ ContentView file found: PASSED"
else
    echo "   ❌ ContentView file not found: FAILED"
fi
echo ""

# Check network connectivity for AI services
echo "6. Checking network connectivity..."

# Test OpenAI API accessibility
if curl -s --head https://api.openai.com | head -n 1 | grep -q "200 OK"; then
    echo "   ✅ OpenAI API accessible: PASSED"
else
    echo "   ⚠️  OpenAI API not accessible: CHECK NETWORK"
fi

# Test if Ollama is running locally
if curl -s http://localhost:11434/api/tags &> /dev/null; then
    echo "   ✅ Ollama service running: PASSED"
else
    echo "   ⚠️  Ollama service not running: OPTIONAL"
    echo "   Install Ollama from https://ollama.ai if you want local AI"
fi
echo ""

# Summary
echo "📋 Setup Summary"
echo "==============="
echo ""
echo "Required components:"
echo "- macOS 14.0+: $(if [[ $(echo "$os_version >= 14.0" | bc -l) -eq 1 ]]; then echo "✅"; else echo "❌"; fi)"
echo "- Xcode 15.0+: $(if command -v xcodebuild &> /dev/null; then echo "✅"; else echo "❌"; fi)"
echo "- Project files: $(if [[ -d "Link2App.xcodeproj" ]]; then echo "✅"; else echo "❌"; fi)"
echo ""
echo "AI Services (at least one recommended):"
echo "- OpenAI API access: $(if curl -s --head https://api.openai.com | head -n 1 | grep -q "200 OK"; then echo "✅"; else echo "❌"; fi)"
echo "- Ollama local service: $(if curl -s http://localhost:11434/api/tags &> /dev/null; then echo "✅"; else echo "❌"; fi)"
echo ""

# Instructions
echo "🚀 Next Steps"
echo "============"
echo ""
echo "1. Open Link2App.xcodeproj in Xcode"
echo "2. Select your target device (Mac)"
echo "3. Build and run the project (⌘+R)"
echo "4. Configure AI services in Settings"
echo ""
echo "For detailed setup instructions, see USAGE_GUIDE.md"
echo ""

# Optional: Check for common issues
echo "🔧 Troubleshooting"
echo "=================="
echo ""

# Check for common Xcode issues
if [[ -d "~/Library/Developer/Xcode/DerivedData" ]]; then
    derived_data_size=$(du -sh ~/Library/Developer/Xcode/DerivedData | cut -f1)
    echo "- DerivedData size: $derived_data_size"
    echo "  If build issues occur, try cleaning DerivedData"
fi

# Check available disk space
available_space=$(df -h . | awk 'NR==2 {print $4}')
echo "- Available disk space: $available_space"

echo ""
echo "Link2App setup verification complete! 🎉"