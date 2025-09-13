# Link2App

Convert any website into an iOS app using AI-powered code generation.

## Features

- **macOS Silicon Native App**: Built specifically for Apple Silicon Macs
- **AI-Powered Code Generation**: Uses OpenAI GPT models or local Ollama models
- **Dynamic UI**: Interactive interface that responds to AI suggestions
- **Website Analysis**: Automatically extracts content, structure, and design elements
- **SwiftUI Code Generation**: Generates modern, production-ready iOS code
- **Project Export**: Creates complete iOS app projects ready for Xcode
- **Multiple AI Providers**: Support for both OpenAI API and local Ollama models

## Prerequisites

- macOS 14.0 or later (Apple Silicon recommended)
- Xcode 15.0 or later
- OpenAI API key (for OpenAI provider) or Ollama installation (for local AI)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ttracx/link2app.git
   cd link2app
   ```

2. Open the project in Xcode:
   ```bash
   open Link2App.xcodeproj
   ```

3. Build and run the project (⌘+R)

## Setup

### OpenAI Configuration
1. Get an API key from [OpenAI](https://platform.openai.com/api-keys)
2. Open Link2App and go to Settings
3. Enter your API key in the OpenAI tab
4. Select your preferred model (GPT-4 recommended)

### Ollama Configuration (Local AI)
1. Install [Ollama](https://ollama.ai)
2. Pull a model: `ollama pull llama2`
3. Start Ollama: `ollama serve`
4. In Link2App settings, configure the Ollama endpoint (default: http://localhost:11434)

## Usage

1. **Enter Website URL**: Input the website you want to convert
2. **Preview Website**: View the website to understand its structure
3. **Select AI Provider**: Choose between OpenAI or Ollama
4. **Generate iOS App**: Click "Generate iOS App" to start the conversion
5. **Review Generated Code**: View the generated SwiftUI code
6. **Apply AI Suggestions**: Use dynamic suggestions to improve the app
7. **Export Project**: Save the complete iOS project to your desired location

## AI Code Generation

The app uses sophisticated prompts to generate high-quality iOS code:

- Analyzes website structure, content, and design
- Creates native SwiftUI components
- Implements responsive layouts for iPhone and iPad
- Includes proper navigation and state management
- Adds error handling and best practices
- Generates complete project structure with dependencies

## Dynamic UI Features

- **Real-time Suggestions**: AI provides contextual suggestions for improvements
- **Interactive Code Editing**: Apply suggestions with one click
- **Live Preview**: See website content while generating code
- **Progress Tracking**: Visual feedback during code generation
- **Export Management**: Easy project export with proper structure

## Technical Architecture

- **SwiftUI**: Modern declarative UI framework
- **WebKit**: For website preview and content extraction
- **URLSession**: HTTP networking for AI API calls
- **FileManager**: Project export and file management
- **@StateObject/@ObservableObject**: Reactive state management
- **Async/Await**: Modern concurrency for AI operations

## Project Structure

```
Link2App/
├── Link2AppApp.swift          # Main app entry point
├── ContentView.swift          # Main UI interface
├── SettingsView.swift         # Configuration settings
├── AIManager.swift            # OpenAI API integration
├── OllamaManager.swift        # Ollama local AI integration
├── WebsiteConverter.swift     # Website analysis and project export
├── Assets.xcassets/           # App icons and colors
└── Info.plist               # App configuration
```

## Generated Project Structure

When you export a generated iOS app, it creates:

```
MyiOSApp/
├── ContentView.swift          # Generated SwiftUI code
├── App.swift                  # iOS app entry point
├── Package.swift              # Swift Package Manager configuration
├── README.md                  # Project documentation
└── .gitignore                # Git ignore file
```

## Supported Website Types

- **Static Websites**: HTML, CSS, JavaScript sites
- **E-commerce**: Product catalogs, shopping interfaces
- **Blogs**: Content-heavy sites with articles
- **Landing Pages**: Marketing and promotional sites
- **Web Apps**: Interactive web applications
- **Portfolios**: Creative and professional showcases

## AI Model Support

### OpenAI Models
- GPT-4 (recommended for best quality)
- GPT-3.5 Turbo (faster, cost-effective)
- GPT-4 Turbo (latest features)

### Ollama Models
- Llama 2 (7B, 13B, 70B)
- Code Llama (specialized for code generation)
- Mistral (lightweight alternative)
- Custom fine-tuned models

## Privacy & Security

- **Local Processing**: Website content processed locally
- **Secure API**: OpenAI API calls use HTTPS
- **No Data Storage**: No personal data stored permanently
- **Sandboxed**: App runs in macOS sandbox for security
- **User Control**: Full control over AI provider and data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- **Issues**: Report bugs and feature requests on GitHub
- **Discussions**: Join community discussions
- **Documentation**: Full documentation available in the wiki

## Roadmap

- [ ] Support for React Native generation
- [ ] Flutter code generation
- [ ] Advanced UI component recognition
- [ ] Custom AI model training
- [ ] Cloud-based processing option
- [ ] Team collaboration features
- [ ] Template marketplace

---

**Link2App** - Transforming the web into native mobile experiences with AI.
