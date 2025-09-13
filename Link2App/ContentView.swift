import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject private var aiManager: AIManager
    @EnvironmentObject private var ollamaManager: OllamaManager
    @StateObject private var websiteConverter = WebsiteConverter()
    
    @State private var websiteURL: String = ""
    @State private var isGenerating = false
    @State private var showPreview = false
    @State private var generatedCode = ""
    @State private var aiSuggestions: [String] = []
    @State private var selectedAIProvider: AIProvider = .openAI
    
    enum AIProvider: String, CaseIterable {
        case openAI = "OpenAI"
        case ollama = "Ollama"
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                Text("Link2App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Website URL")
                        .font(.headline)
                    
                    TextField("Enter website URL", text: $websiteURL)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Preview Website") {
                        showPreview = true
                        websiteConverter.loadWebsite(url: websiteURL)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(websiteURL.isEmpty)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("AI Provider")
                        .font(.headline)
                    
                    Picker("AI Provider", selection: $selectedAIProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Button("Generate iOS App") {
                        generateIOSApp()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(websiteURL.isEmpty || isGenerating)
                    
                    if isGenerating {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating...")
                                .font(.caption)
                        }
                    }
                }
                
                Divider()
                
                if !aiSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI Suggestions")
                            .font(.headline)
                        
                        ForEach(aiSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                applySuggestion(suggestion)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 300, maxWidth: 300)
        } detail: {
            // Main content area
            HSplitView {
                // Website preview
                if showPreview {
                    VStack {
                        Text("Website Preview")
                            .font(.headline)
                            .padding(.top)
                        
                        WebView(url: websiteURL)
                            .frame(minWidth: 400, minHeight: 500)
                    }
                } else {
                    VStack {
                        Image(systemName: "globe")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Enter a website URL to preview")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Generated code view
                VStack {
                    Text("Generated iOS Code")
                        .font(.headline)
                        .padding(.top)
                    
                    if generatedCode.isEmpty {
                        VStack {
                            Image(systemName: "swift")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            Text("Generated Swift code will appear here")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            Text(generatedCode)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .padding()
                        
                        HStack {
                            Button("Copy Code") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(generatedCode, forType: .string)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Export Project") {
                                exportProject()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(generatedCode.isEmpty)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(minWidth: 400)
            }
        }
        .navigationTitle("Link2App")
    }
    
    private func generateIOSApp() {
        isGenerating = true
        aiSuggestions.removeAll()
        
        Task {
            do {
                let websiteContent = await websiteConverter.extractContent()
                
                let prompt = """
                Convert this website into a native iOS SwiftUI app. 
                Website URL: \(websiteURL)
                Website Content: \(websiteContent)
                
                Generate a complete SwiftUI view that recreates the website's functionality and design.
                Include navigation, UI components, and data handling as needed.
                Make it optimized for iPhone and iPad.
                """
                
                let code: String
                if selectedAIProvider == .openAI {
                    code = try await aiManager.generateCode(prompt: prompt)
                } else {
                    code = try await ollamaManager.generateCode(prompt: prompt)
                }
                
                await MainActor.run {
                    generatedCode = code
                    isGenerating = false
                    generateAISuggestions()
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    // Handle error
                    print("Error generating code: \(error)")
                }
            }
        }
    }
    
    private func generateAISuggestions() {
        aiSuggestions = [
            "Add dark mode support",
            "Implement offline caching",
            "Add pull-to-refresh",
            "Enhance animations",
            "Add haptic feedback"
        ]
    }
    
    private func applySuggestion(_ suggestion: String) {
        // Apply AI suggestion to improve the generated code
        Task {
            do {
                let improvedPrompt = """
                Improve the following iOS SwiftUI code by applying this suggestion: \(suggestion)
                
                Current code:
                \(generatedCode)
                """
                
                let improvedCode: String
                if selectedAIProvider == .openAI {
                    improvedCode = try await aiManager.generateCode(prompt: improvedPrompt)
                } else {
                    improvedCode = try await ollamaManager.generateCode(prompt: improvedPrompt)
                }
                
                await MainActor.run {
                    generatedCode = improvedCode
                }
            } catch {
                print("Error applying suggestion: \(error)")
            }
        }
    }
    
    private func exportProject() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.folder]
        panel.nameFieldStringValue = "MyiOSApp"
        panel.message = "Choose where to save your iOS project"
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                websiteConverter.exportProject(code: generatedCode, to: url)
            }
        }
    }
}

struct WebView: NSViewRepresentable {
    let url: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AIManager())
        .environmentObject(OllamaManager())
}