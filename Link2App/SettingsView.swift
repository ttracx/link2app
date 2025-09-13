import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var aiManager: AIManager
    @EnvironmentObject private var ollamaManager: OllamaManager
    @AppStorage("openai_api_key") private var openAIKey: String = ""
    @AppStorage("ollama_endpoint") private var ollamaEndpoint: String = "http://localhost:11434"
    @AppStorage("default_ai_provider") private var defaultProvider: String = "OpenAI"
    
    var body: some View {
        TabView {
            // OpenAI Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("OpenAI Configuration")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("API Key")
                        .font(.headline)
                    
                    SecureField("Enter your OpenAI API key", text: $openAIKey)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: openAIKey) { newValue in
                            aiManager.setAPIKey(newValue)
                        }
                    
                    Text("Get your API key from: https://platform.openai.com/api-keys")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Model")
                        .font(.headline)
                    
                    Picker("Model", selection: $aiManager.selectedModel) {
                        Text("GPT-4").tag("gpt-4")
                        Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                        Text("GPT-4 Turbo").tag("gpt-4-turbo-preview")
                    }
                    .pickerStyle(.menu)
                }
                
                Button("Test Connection") {
                    testOpenAIConnection()
                }
                .buttonStyle(.borderedProminent)
                
                if !aiManager.connectionStatus.isEmpty {
                    Text(aiManager.connectionStatus)
                        .foregroundColor(aiManager.isConnected ? .green : .red)
                }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("OpenAI", systemImage: "brain.head.profile")
            }
            
            // Ollama Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("Ollama Configuration")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Endpoint URL")
                        .font(.headline)
                    
                    TextField("Ollama endpoint", text: $ollamaEndpoint)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: ollamaEndpoint) { newValue in
                            ollamaManager.setEndpoint(newValue)
                        }
                    
                    Text("Default: http://localhost:11434")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Models")
                        .font(.headline)
                    
                    if ollamaManager.availableModels.isEmpty {
                        Text("No models found. Make sure Ollama is running.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Model", selection: $ollamaManager.selectedModel) {
                            ForEach(ollamaManager.availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                HStack {
                    Button("Refresh Models") {
                        ollamaManager.fetchAvailableModels()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Connection") {
                        testOllamaConnection()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if !ollamaManager.connectionStatus.isEmpty {
                    Text(ollamaManager.connectionStatus)
                        .foregroundColor(ollamaManager.isConnected ? .green : .red)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Installation Instructions")
                        .font(.headline)
                    
                    Text("1. Download Ollama from: https://ollama.ai")
                    Text("2. Install and run Ollama")
                    Text("3. Pull a model: ollama pull llama2")
                    Text("4. Verify it's running: curl http://localhost:11434")
                    
                    Button("Open Ollama Website") {
                        NSWorkspace.shared.open(URL(string: "https://ollama.ai")!)
                    }
                    .buttonStyle(.link)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("Ollama", systemImage: "server.rack")
            }
            
            // General Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("General Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Default AI Provider")
                        .font(.headline)
                    
                    Picker("Default Provider", selection: $defaultProvider) {
                        Text("OpenAI").tag("OpenAI")
                        Text("Ollama").tag("Ollama")
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Export Settings")
                        .font(.headline)
                    
                    Toggle("Include dependencies", isOn: .constant(true))
                    Toggle("Generate README", isOn: .constant(true))
                    Toggle("Create .gitignore", isOn: .constant(true))
                }
                
                Spacer()
                
                HStack {
                    Button("Reset Settings") {
                        resetSettings()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Text("Link2App v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            aiManager.setAPIKey(openAIKey)
            ollamaManager.setEndpoint(ollamaEndpoint)
            ollamaManager.fetchAvailableModels()
        }
    }
    
    private func testOpenAIConnection() {
        aiManager.testConnection()
    }
    
    private func testOllamaConnection() {
        ollamaManager.testConnection()
    }
    
    private func resetSettings() {
        openAIKey = ""
        ollamaEndpoint = "http://localhost:11434"
        defaultProvider = "OpenAI"
        aiManager.setAPIKey("")
        ollamaManager.setEndpoint("http://localhost:11434")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AIManager())
        .environmentObject(OllamaManager())
}