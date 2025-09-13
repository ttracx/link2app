# Link2App Architecture

## Overview

Link2App is a macOS application built with SwiftUI that converts websites into native iOS applications using AI-powered code generation. The architecture follows MVVM patterns with reactive programming using Combine framework.

## Core Components

### 1. Application Layer (`Link2AppApp.swift`)

The main application entry point that:
- Configures the app's window and scene management
- Initializes global state managers (AIManager, OllamaManager)
- Sets up environment objects for dependency injection
- Manages app lifecycle and settings windows

```swift
@main
struct Link2AppApp: App {
    @StateObject private var aiManager = AIManager()
    @StateObject private var ollamaManager = OllamaManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(aiManager)
                .environmentObject(ollamaManager)
        }
        Settings {
            SettingsView()
                .environmentObject(aiManager)
                .environmentObject(ollamaManager)
        }
    }
}
```

### 2. User Interface Layer

#### ContentView (`ContentView.swift`)
The main user interface implementing a split-view layout:

**Left Sidebar:**
- Website URL input field
- AI provider selection
- Generate button with progress indicator
- Dynamic AI suggestions list

**Main Content Area:**
- Website preview using WKWebView
- Generated SwiftUI code display
- Code manipulation tools (copy, export)

**Key Features:**
- Reactive UI updates using `@State` and `@Published`
- Async operations with proper error handling
- Dynamic suggestion system
- File export functionality

#### SettingsView (`SettingsView.swift`)
Tabbed configuration interface:

**OpenAI Tab:**
- API key configuration (SecureField)
- Model selection picker
- Connection testing
- Usage guidelines

**Ollama Tab:**
- Endpoint URL configuration
- Available models list
- Local service status
- Installation instructions

**General Tab:**
- Default AI provider selection
- Export preferences
- App information and reset options

### 3. AI Integration Layer

#### AIManager (`AIManager.swift`)
Handles OpenAI API integration:

**Core Functionality:**
- API key management and validation
- Model selection (GPT-4, GPT-3.5 Turbo, GPT-4 Turbo)
- HTTP requests to OpenAI endpoints
- Response parsing and error handling
- Connection status monitoring

**Key Methods:**
```swift
func generateCode(prompt: String) async throws -> String
func testConnection()
func setAPIKey(_ key: String)
```

**Error Handling:**
- Custom error types (AIError enum)
- Network connectivity issues
- API quota and authentication errors
- Malformed response handling

#### OllamaManager (`OllamaManager.swift`)
Manages local Ollama AI service:

**Core Functionality:**
- Local endpoint configuration
- Model discovery and management
- Streaming and non-streaming generation
- Service health monitoring

**Key Methods:**
```swift
func generateCode(prompt: String) async throws -> String
func generateCodeStream(prompt: String) -> AsyncThrowingStream<String, Error>
func fetchAvailableModels()
func testConnection()
```

**Advanced Features:**
- Real-time streaming responses
- Multiple model support
- Local privacy preservation
- Offline capability

### 4. Website Analysis Layer

#### WebsiteConverter (`WebsiteConverter.swift`)
Handles website content extraction and project generation:

**Website Analysis:**
- WebKit integration for site loading
- JavaScript-based content extraction
- Metadata collection (title, description, headings)
- Image and link inventory
- Content structure analysis

**Content Extraction Pipeline:**
```swift
func extractContent() async -> String {
    // JavaScript execution in WebView
    // DOM traversal and content collection
    // Structured data formatting
    // Error handling for inaccessible content
}
```

**Project Export:**
- Complete iOS project structure generation
- SwiftUI code file creation
- Package.swift configuration
- README and documentation generation
- Git repository initialization

### 5. Data Flow Architecture

```
User Input (Website URL)
        ↓
Website Loading (WKWebView)
        ↓
Content Extraction (JavaScript)
        ↓
AI Prompt Generation
        ↓
AI API Call (OpenAI/Ollama)
        ↓
Code Generation Response
        ↓
UI Update (Generated Code Display)
        ↓
Optional: Apply AI Suggestions
        ↓
Project Export (File System)
```

## Design Patterns

### 1. MVVM (Model-View-ViewModel)

**Models:**
- Website content data structures
- AI response models
- Configuration settings

**Views:**
- ContentView, SettingsView
- Custom UI components (WebView, FeatureCard)
- SwiftUI reactive components

**ViewModels:**
- AIManager, OllamaManager, WebsiteConverter
- Handle business logic and state management
- Provide data binding for views

### 2. Observer Pattern

Using Combine framework for reactive programming:

```swift
@Published var isConnected = false
@Published var connectionStatus = ""
@Published var generatedCode = ""
```

### 3. Dependency Injection

Environment objects provide dependencies:

```swift
.environmentObject(aiManager)
.environmentObject(ollamaManager)
```

### 4. Strategy Pattern

AI provider selection allows switching between different implementation strategies:

```swift
let code: String
if selectedAIProvider == .openAI {
    code = try await aiManager.generateCode(prompt: prompt)
} else {
    code = try await ollamaManager.generateCode(prompt: prompt)
}
```

## Security Architecture

### 1. Sandboxing
- macOS app sandbox enabled
- Limited file system access
- Network permissions for AI APIs
- User-selected file access for exports

### 2. API Key Protection
- SecureField for password input
- Keys stored in UserDefaults (consider Keychain for production)
- No key logging or persistence in plain text

### 3. Network Security
- HTTPS enforcement for OpenAI API
- Certificate validation
- Request/response encryption

### 4. Data Privacy
- Website content processed locally
- No persistent storage of sensitive data
- User control over data sharing

## Performance Optimizations

### 1. Async/Await Pattern
- Non-blocking UI operations
- Proper task cancellation
- Error propagation

### 2. Memory Management
- WeakSelf references in closures
- Proper object lifecycle management
- WebView memory optimization

### 3. Network Efficiency
- Request batching where possible
- Connection reuse
- Timeout handling

### 4. UI Responsiveness
- Background processing for heavy operations
- Progressive loading indicators
- Smooth animations and transitions

## Error Handling Strategy

### 1. Custom Error Types
```swift
enum AIError: LocalizedError {
    case noAPIKey
    case apiError(String)
    case invalidResponse
}
```

### 2. Graceful Degradation
- Fallback UI states
- User-friendly error messages
- Recovery suggestions

### 3. Logging and Debugging
- Console logging for development
- Error state preservation
- Debug information collection

## Testing Architecture

### 1. Unit Testing Strategy
- AI manager functionality
- Website content extraction
- Code generation validation
- Configuration management

### 2. Integration Testing
- API connectivity tests
- File export validation
- UI interaction testing

### 3. Mock Services
- Mock AI responses for testing
- Fake website content
- Simulated network conditions

## Deployment Architecture

### 1. Build Configuration
- Debug vs Release builds
- Code signing setup
- Entitlements configuration

### 2. Distribution
- Mac App Store compatibility
- Developer ID signing
- Notarization support

### 3. Update Mechanism
- Version checking
- Automatic update notifications
- Migration handling

## Extensibility Points

### 1. AI Provider Interface
- Pluggable AI service providers
- Custom model support
- Local/remote hybrid approaches

### 2. Output Format Support
- React Native generation
- Flutter code generation
- Custom template systems

### 3. Website Analysis Enhancement
- Custom extraction rules
- Advanced content recognition
- Multi-page site support

## Future Architecture Considerations

### 1. Cloud Integration
- Cloud-based processing options
- Collaborative features
- Template sharing

### 2. Advanced AI Features
- Multi-modal input (images, videos)
- Custom fine-tuned models
- Real-time code suggestions

### 3. Enterprise Features
- Team collaboration
- Custom branding
- API access for automation

---

This architecture supports the current requirements while providing flexibility for future enhancements and scalability needs.