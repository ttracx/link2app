import SwiftUI

struct ProjectEditView: View {
    @ObservedObject var project: Project
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var projectName: String
    @State private var websiteURL: String
    @State private var selectedAIModel: AIModel
    @State private var customizations: ProjectCustomizations
    
    init(project: Project, viewModel: WebsiteConversionViewModel) {
        self.project = project
        self.viewModel = viewModel
        self._projectName = State(initialValue: project.name)
        self._websiteURL = State(initialValue: project.websiteURL)
        self._selectedAIModel = State(initialValue: project.aiModel)
        self._customizations = State(initialValue: project.customizations)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Website URL", text: $websiteURL)
                            .textFieldStyle(.roundedBorder)
                        
                        if !websiteURL.isEmpty && !viewModel.validateURL(websiteURL) {
                            Text("Please enter a valid URL (e.g., https://example.com)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("AI Configuration") {
                    Picker("AI Model", selection: $selectedAIModel) {
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
                    .pickerStyle(.radioGroup)
                }
                
                Section("App Customization") {
                    TextField("App Name", text: Binding(
                        get: { customizations.appName ?? "" },
                        set: { customizations.appName = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Bundle Identifier", text: Binding(
                        get: { customizations.bundleIdentifier ?? "" },
                        set: { customizations.bundleIdentifier = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Picker("Target Devices", selection: Binding(
                        get: { Set(customizations.targetDevices) },
                        set: { customizations.targetDevices = Array($0) }
                    )) {
                        ForEach(TargetDevice.allCases, id: \.self) { device in
                            Text(device.displayName).tag(device)
                        }
                    }
                    .pickerStyle(.checkboxGroup)
                    
                    Picker("Minimum iOS Version", selection: $customizations.minimumiOSVersion) {
                        Text("iOS 14.0").tag("14.0")
                        Text("iOS 15.0").tag("15.0")
                        Text("iOS 16.0").tag("16.0")
                        Text("iOS 17.0").tag("17.0")
                    }
                }
                
                Section("Features") {
                    ForEach(AppFeature.allCases, id: \.self) { feature in
                        Toggle(feature.displayName, isOn: Binding(
                            get: { customizations.includeFeatures.contains(feature) },
                            set: { isOn in
                                if isOn {
                                    customizations.includeFeatures.append(feature)
                                } else {
                                    customizations.includeFeatures.removeAll { $0 == feature }
                                }
                            }
                        ))
                    }
                }
                
                Section("Styling") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Primary Color (Hex)", text: Binding(
                            get: { customizations.customStyling?.primaryColor ?? "" },
                            set: { customizations.customStyling?.primaryColor = $0.isEmpty ? nil : $0 }
                        ))
                        
                        TextField("Secondary Color (Hex)", text: Binding(
                            get: { customizations.customStyling?.secondaryColor ?? "" },
                            set: { customizations.customStyling?.secondaryColor = $0.isEmpty ? nil : $0 }
                        ))
                        
                        TextField("Font Family", text: Binding(
                            get: { customizations.customStyling?.fontFamily ?? "" },
                            set: { customizations.customStyling?.fontFamily = $0.isEmpty ? nil : $0 }
                        ))
                        
                        HStack {
                            Text("Corner Radius")
                            Spacer()
                            Slider(value: Binding(
                                get: { customizations.customStyling?.cornerRadius ?? 8.0 },
                                set: { customizations.customStyling?.cornerRadius = $0 }
                            ), in: 0...20, step: 1)
                            Text("\(Int(customizations.customStyling?.cornerRadius ?? 8.0))")
                                .frame(width: 30)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(projectName.isEmpty || websiteURL.isEmpty || !viewModel.validateURL(websiteURL))
                }
            }
        }
        .frame(width: 600, height: 700)
    }
    
    private func saveProject() {
        var updatedProject = project
        updatedProject.name = projectName
        updatedProject.websiteURL = websiteURL
        updatedProject.aiModel = selectedAIModel
        updatedProject.customizations = customizations
        updatedProject.lastModified = Date()
        
        viewModel.updateProject(updatedProject)
        dismiss()
    }
}

#Preview {
    ProjectEditView(
        project: Project(name: "Sample App", websiteURL: "https://example.com"),
        viewModel: WebsiteConversionViewModel()
    )
}