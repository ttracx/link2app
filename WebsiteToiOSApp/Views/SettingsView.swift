import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var openAIKey = ""
    @State private var ollamaURL = "http://localhost:11434"
    @State private var ollamaModel = "llama2"
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var showingAPIKeyAlert = false
    @State private var showingOllamaAlert = false
    @State private var selectedAIModel: AIModel = .openAI
    @State private var autoSave = true
    @State private var showPreview = true
    @State private var enableAnalytics = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "gear.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Configure your AI models and app preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 24) {
                        // AI Configuration Section
                        SettingsSection(
                            title: "AI Configuration",
                            icon: "brain.head.profile",
                            color: .blue
                        ) {
                            VStack(spacing: 20) {
                                AIModelPicker(selectedModel: $selectedAIModel)
                                
                                if selectedAIModel == .openAI {
                                    OpenAISettingsView(
                                        apiKey: $openAIKey,
                                        onTestConnection: testOpenAIConnection
                                    )
                                } else {
                                    OllamaSettingsView(
                                        baseURL: $ollamaURL,
                                        selectedModel: $ollamaModel,
                                        availableModels: availableModels,
                                        isLoadingModels: isLoadingModels,
                                        onLoadModels: loadAvailableModels,
                                        onTestConnection: testOllamaConnection
                                    )
                                }
                            }
                        }
                        
                        // App Settings Section
                        SettingsSection(
                            title: "App Preferences",
                            icon: "app.badge",
                            color: .green
                        ) {
                            VStack(spacing: 16) {
                                ToggleRow(
                                    title: "Auto-save projects",
                                    subtitle: "Automatically save changes to your projects",
                                    isOn: $autoSave,
                                    icon: "square.and.arrow.down"
                                )
                                
                                ToggleRow(
                                    title: "Show preview in sidebar",
                                    subtitle: "Display website preview in the sidebar",
                                    isOn: $showPreview,
                                    icon: "eye"
                                )
                                
                                ToggleRow(
                                    title: "Enable analytics",
                                    subtitle: "Help improve the app by sharing anonymous usage data",
                                    isOn: $enableAnalytics,
                                    icon: "chart.bar"
                                )
                            }
                        }
                        
                        // About Section
                        SettingsSection(
                            title: "About",
                            icon: "info.circle",
                            color: .purple
                        ) {
                            VStack(spacing: 16) {
                                InfoRow(title: "Version", value: "1.0.0", icon: "tag")
                                InfoRow(title: "Build", value: "1", icon: "hammer")
                                
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Check for Updates")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color.white,
                        colorScheme == .dark ? Color.gray.opacity(0.1) : Color.blue.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 600, height: 700)
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

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct AIModelPicker: View {
    @Binding var selectedModel: AIModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Model")
                .font(.headline)
            
            Picker("AI Model", selection: $selectedModel) {
                ForEach(AIModel.allCases, id: \.self) { model in
                    VStack(alignment: .leading) {
                        Text(model.displayName)
                        Text(model.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(model)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct OpenAISettingsView: View {
    @Binding var apiKey: String
    let onTestConnection: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.headline)
                
                SecureField("Enter your OpenAI API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button("Test Connection") {
                onTestConnection()
            }
            .buttonStyle(.bordered)
            .disabled(apiKey.isEmpty)
        }
    }
}

struct OllamaSettingsView: View {
    @Binding var baseURL: String
    @Binding var selectedModel: String
    let availableModels: [String]
    let isLoadingModels: Bool
    let onLoadModels: () -> Void
    let onTestConnection: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Base URL")
                    .font(.headline)
                
                TextField("Ollama URL", text: $baseURL)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Model")
                    .font(.headline)
                
                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack(spacing: 12) {
                Button("Load Models") {
                    onLoadModels()
                }
                .buttonStyle(.bordered)
                .disabled(isLoadingModels)
                
                Button("Test Connection") {
                    onTestConnection()
                }
                .buttonStyle(.bordered)
                .disabled(baseURL.isEmpty)
            }
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

#Preview {
    SettingsView(viewModel: WebsiteConversionViewModel())
}