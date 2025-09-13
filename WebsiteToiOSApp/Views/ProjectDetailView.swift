import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @State private var showingAnalysis = false
    @State private var showingCode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(project.websiteURL)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: project.status)
                }
                
                HStack(spacing: 20) {
                    InfoItem(title: "Created", value: DateFormatter.shortDate.string(from: project.createdAt))
                    InfoItem(title: "Modified", value: DateFormatter.shortDate.string(from: project.lastModified))
                    InfoItem(title: "AI Model", value: project.aiModel.displayName)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Website Analysis Section
                    if let analysis = viewModel.analysisResult {
                        AnalysisSection(analysis: analysis)
                    } else if project.status == .analyzing {
                        AnalysisProgressView()
                    } else {
                        AnalysisPromptView {
                            Task {
                                await viewModel.analyzeWebsite(project.websiteURL)
                            }
                        }
                    }
                    
                    // Code Generation Section
                    if let code = viewModel.generatedCode {
                        CodeGenerationSection(code: code)
                    } else if project.status == .generating {
                        GenerationProgressView()
                    } else if viewModel.analysisResult != nil {
                        GenerationPromptView {
                            Task {
                                await viewModel.generateiOSApp()
                            }
                        }
                    }
                    
                    // Export Section
                    if project.status == .completed {
                        ExportSection(project: project, code: viewModel.generatedCode)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusBadge: View {
    let status: ProjectStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.systemImage)
                .font(.caption)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.2))
        .foregroundColor(statusColor)
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .draft: return .gray
        case .analyzing: return .blue
        case .generating: return .orange
        case .completed: return .green
        case .error: return .red
        }
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct AnalysisSection: View {
    let analysis: WebsiteAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Website Analysis", icon: "magnifyingglass")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalysisCard(title: "Title", value: analysis.title)
                AnalysisCard(title: "Description", value: analysis.description ?? "No description")
                AnalysisCard(title: "Layout", value: analysis.structure.layout.rawValue.capitalized)
                AnalysisCard(title: "Sections", value: "\(analysis.structure.mainSections.count)")
                AnalysisCard(title: "Images", value: "\(analysis.images.count)")
                AnalysisCard(title: "Forms", value: "\(analysis.forms.count)")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct AnalysisCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct AnalysisProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing website...")
                .font(.headline)
            Text("This may take a few moments")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct AnalysisPromptView: View {
    let onAnalyze: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Ready to Analyze")
                .font(.headline)
            
            Text("Click the button below to analyze the website structure and content")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Analyze Website") {
                onAnalyze()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct CodeGenerationSection: View {
    let code: GeneratedCode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Generated iOS App", icon: "iphone")
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Project: \(code.projectName)")
                        .font(.headline)
                    Spacer()
                    Text("\(code.swiftFiles.count) files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Bundle ID: \(code.bundleIdentifier)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !code.dependencies.isEmpty {
                    Text("Dependencies:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(code.dependencies, id: \.name) { dependency in
                        HStack {
                            Text("• \(dependency.name)")
                                .font(.caption)
                            Spacer()
                            Text(dependency.version)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

struct GenerationProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Generating iOS App...")
                .font(.headline)
            Text("AI is creating your native iOS app")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct GenerationPromptView: View {
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gear.circle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Ready to Generate")
                .font(.headline)
            
            Text("Generate your iOS app using AI-powered code generation")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate iOS App") {
                onGenerate()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ExportSection: View {
    let project: Project
    let code: GeneratedCode?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Export & Build", icon: "square.and.arrow.down")
            
            VStack(spacing: 12) {
                Button("Export Xcode Project") {
                    // Export functionality
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Open in Xcode") {
                    // Open in Xcode functionality
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Build for Device") {
                    // Build functionality
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ProjectDetailView(
        project: Project(name: "Sample App", websiteURL: "https://example.com"),
        viewModel: WebsiteConversionViewModel()
    )
}