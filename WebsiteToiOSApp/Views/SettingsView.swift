import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var openAIKey = ""
    @State private var ollamaURL = "http://localhost:11434"
    @State private var ollamaModel = "llama2"
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var showingAPIKeyAlert = false
    @State private var showingOllamaAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("AI Configuration") {
                    Picker("AI Model", selection: .constant(AIModel.openAI)) {
                        ForEach(AIModel.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("OpenAI Settings") {
                    HStack {
                        Text("API Key")
                        Spacer()
                        SecureField("Enter API key", text: $openAIKey)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }
                    
                    Button("Test Connection") {
                        testOpenAIConnection()
                    }
                    .disabled(openAIKey.isEmpty)
                }
                
                Section("Ollama Settings") {
                    HStack {
                        Text("Base URL")
                        Spacer()
                        TextField("Ollama URL", text: $ollamaURL)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }
                    
                    HStack {
                        Text("Model")
                        Spacer()
                        Picker("Model", selection: $ollamaModel) {
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 200)
                    }
                    
                    HStack {
                        Button("Load Models") {
                            loadAvailableModels()
                        }
                        .disabled(isLoadingModels)
                        
                        Spacer()
                        
                        Button("Test Connection") {
                            testOllamaConnection()
                        }
                        .disabled(ollamaURL.isEmpty)
                    }
                }
                
                Section("App Settings") {
                    Toggle("Auto-save projects", isOn: .constant(true))
                    Toggle("Show preview in sidebar", isOn: .constant(true))
                    Toggle("Enable analytics", isOn: .constant(false))
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Check for Updates") {
                        // Check for updates
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadSettings()
        }
        .alert("API Key Saved", isPresented: $showingAPIKeyAlert) {
            Button("OK") { }
        } message: {
            Text("Your OpenAI API key has been saved successfully.")
        }
        .alert("Ollama Connected", isPresented: $showingOllamaAlert) {
            Button("OK") { }
        } message: {
            Text("Successfully connected to Ollama.")
        }
    }
    
    private func loadSettings() {
        openAIKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        ollamaURL = UserDefaults.standard.string(forKey: "ollama_base_url") ?? "http://localhost:11434"
        ollamaModel = UserDefaults.standard.string(forKey: "ollama_model") ?? "llama2"
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(openAIKey, forKey: "openai_api_key")
        UserDefaults.standard.set(ollamaURL, forKey: "ollama_base_url")
        UserDefaults.standard.set(ollamaModel, forKey: "ollama_model")
    }
    
    private func testOpenAIConnection() {
        Task {
            do {
                let service = OpenAIService()
                service.setAPIKey(openAIKey)
                let isValid = try await service.validateAPIKey()
                
                await MainActor.run {
                    if isValid {
                        showingAPIKeyAlert = true
                    }
                }
            } catch {
                // Handle error
            }
        }
    }
    
    private func testOllamaConnection() {
        Task {
            do {
                let service = OllamaService()
                service.setBaseURL(ollamaURL)
                let isValid = try await service.validateConnection()
                
                await MainActor.run {
                    if isValid {
                        showingOllamaAlert = true
                    }
                }
            } catch {
                // Handle error
            }
        }
    }
    
    private func loadAvailableModels() {
        isLoadingModels = true
        
        Task {
            do {
                let service = OllamaService()
                service.setBaseURL(ollamaURL)
                let models = try await service.getAvailableModels()
                
                await MainActor.run {
                    availableModels = models
                    isLoadingModels = false
                }
            } catch {
                await MainActor.run {
                    isLoadingModels = false
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: WebsiteConversionViewModel())
}