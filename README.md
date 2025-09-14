# Link2App: Website to iOS App Converter

A powerful macOS app for Apple Silicon that transforms any website into a native iOS app using AI-powered code generation. Built with SwiftUI and supporting both OpenAI and Ollama local models.

## Features

### 🚀 Core Functionality
- **Website Analysis**: Automatically analyzes website structure, content, and styling.
- **AI-Powered Conversion**: Uses OpenAI GPT-4 or Ollama for intelligent code generation.
- **Native iOS Apps**: Creates true native iOS apps, not web wrappers.
- **Dynamic UI**: Enhanced, dynamic user interface for project management.

### 🤖 AI Integration
- **OpenAI Support**: Cloud-based AI with latest GPT models.
- **Ollama Support**: Local AI processing for privacy and offline use.
- **Intelligent Code Generation**: Converts website structure to native iOS components.
- **Customizable Prompts**: Fine-tune AI behavior for specific requirements.

### 📱 iOS App Features
- **SwiftUI Views**: Modern, declarative UI components.
- **WebView Integration**: Seamless web content integration.
- **Native Navigation**: iOS-style navigation patterns.
- **Responsive Design**: Adapts to different screen sizes.
- **Custom Styling**: Maintains website's visual identity.

### 🛠️ Project Management
- **Project Organization**: Manage multiple conversion projects.
- **Real-time Preview**: See analysis and generation progress.
- **Export Options**: Export complete Xcode projects.
- **Settings Management**: Configure AI models and preferences.

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later
- Apple Silicon Mac (M1/M2/M3)
- OpenAI API key (optional, for cloud AI)
- Ollama installation (optional, for local AI)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/ttracx/link2app.git
    cd link2app
    ```
2. Open in Xcode:
    ```bash
    open Link2App.xcodeproj
    ```
3. Build and run the project (⌘+R)

## Configuration

### OpenAI Setup
1. Get an API key from [OpenAI](https://platform.openai.com/api-keys)
2. Open the app and go to Settings
3. Enter your API key in the OpenAI section
4. Test the connection

### Ollama Setup
1. Install Ollama from [ollama.ai](https://ollama.ai)
2. Pull a model: `ollama pull llama2`
3. In app settings, configure Ollama URL (default: http://localhost:11434)
4. Select your preferred model

## Usage

### Creating a New Project
1. Click "New Project" in the sidebar
2. Enter a project name and website URL
3. Choose your preferred AI model
4. Configure additional settings if needed

### Analyzing a Website
1. Select your project
2. Click "Analyze Website"
3. Wait for analysis to complete
4. Review website structure and content

### Generating iOS App
1. After analysis, click "Generate iOS App"
2. AI will create native iOS code
3. Review generated files and dependencies
4. Export the complete Xcode project

### Exporting and Building
1. Once generation is complete, click "Export Xcode Project"
2. Choose a location to save the project
3. Open the project in Xcode
4. Build and run on your device or simulator

## Project Structure

```
Link2App/
├── Models/
│   └── Project.swift                # Data models
├── ViewModels/
│   └── WebsiteConversionViewModel.swift
├── Views/
│   ├── ContentView.swift            # Main app view
│   ├── ProjectDetailView.swift      # Project details
│   └── SettingsView.swift           # Settings and configuration
├── Services/
│   ├── WebsiteAnalyzer.swift        # Website analysis
│   ├── AICodeGenerator.swift        # Code generation
│   ├── OpenAIService.swift          # OpenAI integration
│   └── OllamaService.swift          # Ollama integration
└── Assets.xcassets/                 # App assets
```

## AI Models Supported

### OpenAI
- GPT-4 (recommended)
- GPT-3.5 Turbo
- Custom model selection

### Ollama
- Llama 2
- Code Llama
- Mistral
- Custom models

## Customization Options

### App Features
- Native Navigation
- WebView Integration
- Push Notifications
- Offline Support
- Biometric Authentication
- Deep Linking

### Styling
- Primary/Secondary Colors
- Font Family
- Corner Radius
- Shadow Styles
- Custom Animations

### Target Devices
- iPhone only
- iPad only
- Universal (iPhone + iPad)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- Create an issue for bug reports
- Start a discussion for feature requests
- Check the documentation for common questions

## Roadmap

- [ ] Support for more AI models
- [ ] Advanced customization options
- [ ] Batch processing
- [ ] Cloud project storage
- [ ] Team collaboration features
- [ ] App Store deployment tools

## Acknowledgments

- OpenAI for providing the GPT API
- Ollama for local AI capabilities
- Apple for SwiftUI and development tools
- The open-source community for inspiration and support
