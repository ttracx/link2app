# Development Guide - Website to iOS App

## 🏗️ Project Structure

```
WebsiteToiOSApp/
├── Models/
│   └── Project.swift              # Core data models
├── ViewModels/
│   └── WebsiteConversionViewModel.swift  # Main business logic
├── Views/
│   ├── ContentView.swift          # Main app interface
│   ├── ProjectDetailView.swift    # Project management
│   ├── ProjectEditView.swift      # Project editing
│   └── SettingsView.swift         # App settings
├── Services/
│   ├── WebsiteAnalyzer.swift      # Web scraping & analysis
│   ├── AICodeGenerator.swift      # AI code generation
│   ├── OpenAIService.swift        # OpenAI integration
│   └── OllamaService.swift        # Ollama integration
└── Assets.xcassets/               # App assets
```

## 🔧 Key Components

### 1. Website Analysis (`WebsiteAnalyzer.swift`)
- Uses WebKit to load and analyze websites
- Extracts structure, styles, content, and metadata
- JavaScript-based analysis for comprehensive data collection
- Parses results into structured Swift data models

### 2. AI Code Generation (`AICodeGenerator.swift`)
- Supports both OpenAI and Ollama models
- Generates complete iOS SwiftUI projects
- Creates native iOS components and navigation
- Produces exportable Xcode project files

### 3. Project Management (`WebsiteConversionViewModel.swift`)
- Manages project lifecycle and state
- Handles AI service integration
- Provides export functionality
- Manages project persistence

### 4. User Interface
- **ContentView**: Main split-view interface
- **ProjectDetailView**: Detailed project management
- **ProjectEditView**: Project configuration
- **SettingsView**: AI model configuration

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- Apple Silicon Mac (M1/M2/M3)

### Building the App
```bash
# Run the build script
./build.sh

# Or build manually
xcodebuild -project WebsiteToiOSApp.xcodeproj -scheme WebsiteToiOSApp
```

### Running the App
```bash
# Open in Xcode
open WebsiteToiOSApp.xcodeproj

# Or run from command line
xcodebuild -project WebsiteToiOSApp.xcodeproj -scheme WebsiteToiOSApp -configuration Debug
```

## 🔑 Configuration

### OpenAI Setup
1. Get API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Open app → Settings → OpenAI Settings
3. Enter API key and test connection

### Ollama Setup
1. Install Ollama from [ollama.ai](https://ollama.ai)
2. Pull a model: `ollama pull llama2`
3. Configure in app settings

## 📱 Usage Flow

1. **Create Project**: Click "New Project" in sidebar
2. **Configure**: Set project name, URL, and AI model
3. **Analyze**: Click "Analyze Website" to extract structure
4. **Generate**: Click "Generate iOS App" to create code
5. **Export**: Export complete Xcode project

## 🛠️ Development

### Adding New Features

#### New AI Models
1. Create service class in `Services/`
2. Implement `generateCode(prompt:)` method
3. Add to `AIModel` enum
4. Update `AICodeGenerator` to support new model

#### New Analysis Features
1. Extend `WebsiteAnalysis` struct
2. Add JavaScript analysis code in `WebsiteAnalyzer`
3. Update parsing methods
4. Add UI components in `ProjectDetailView`

#### New Export Formats
1. Extend `GeneratedCode` struct
2. Add export logic in `WebsiteConversionViewModel`
3. Update export UI in `ProjectDetailView`

### Code Style Guidelines
- Use SwiftUI for all UI components
- Follow MVVM architecture pattern
- Use `@MainActor` for UI updates
- Implement proper error handling
- Add comprehensive documentation

### Testing
- Unit tests for business logic
- UI tests for user interactions
- Integration tests for AI services
- Performance tests for large websites

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
- Ensure all files are added to Xcode project
- Check deployment target compatibility
- Verify code signing settings

#### AI Service Errors
- Check API key configuration
- Verify network connectivity
- Check service rate limits

#### Website Analysis Issues
- Ensure website is accessible
- Check CORS policies
- Verify JavaScript execution

### Debug Mode
Enable debug logging by setting:
```swift
UserDefaults.standard.set(true, forKey: "debug_mode")
```

## 📦 Dependencies

### External Services
- **OpenAI API**: Cloud-based AI code generation
- **Ollama**: Local AI model execution

### System Frameworks
- **WebKit**: Website analysis and rendering
- **SwiftUI**: User interface framework
- **Combine**: Reactive programming
- **Foundation**: Core system functionality

## 🔒 Security

### Data Privacy
- Website analysis runs locally
- AI processing can be local (Ollama) or cloud (OpenAI)
- Project data stored locally in UserDefaults
- No data sent to external servers (except AI APIs)

### Sandboxing
- App runs in macOS sandbox
- Network access for AI services
- File system access for project export
- User-selected file access

## 🚀 Deployment

### App Store Distribution
1. Update version numbers
2. Configure code signing
3. Archive and upload to App Store Connect
4. Submit for review

### Direct Distribution
1. Build release configuration
2. Code sign with Developer ID
3. Notarize with Apple
4. Create installer package

## 📈 Performance

### Optimization Tips
- Use async/await for network operations
- Implement proper caching for analysis results
- Optimize JavaScript analysis scripts
- Use lazy loading for large project lists

### Memory Management
- Properly dispose of WebView instances
- Clear analysis data when not needed
- Use weak references in delegates
- Monitor memory usage in Instruments

## 🤝 Contributing

### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Submit pull request
5. Address review feedback

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes
- [ ] Performance impact considered

## 📚 Resources

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WebKit Documentation](https://developer.apple.com/documentation/webkit)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Ollama Documentation](https://ollama.ai/docs)

### Community
- [Swift Forums](https://forums.swift.org)
- [Apple Developer Forums](https://developer.apple.com/forums)
- [OpenAI Community](https://community.openai.com)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.