import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @State private var showingAnalysis = false
    @State private var showingCode = false
    @State private var animateProgress = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(project.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Spacer()
                            
                            StatusBadge(status: project.status)
                        }
                        
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text(project.websiteURL)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                    
                    Spacer()
                }
                
                // Progress indicator
                if project.status == .analyzing || project.status == .generating {
                    ProgressIndicatorView(
                        status: project.status,
                        isAnimating: animateProgress
                    )
                }
                
                // Info cards
                HStack(spacing: 16) {
                    InfoCard(
                        title: "Created",
                        value: DateFormatter.shortDate.string(from: project.createdAt),
                        icon: "calendar",
                        color: .blue
                    )
                    
                    InfoCard(
                        title: "Modified",
                        value: DateFormatter.shortDate.string(from: project.lastModified),
                        icon: "clock",
                        color: .orange
                    )
                    
                    InfoCard(
                        title: "AI Model",
                        value: project.aiModel.displayName,
                        icon: "brain.head.profile",
                        color: .purple
                    )
                }
            }
            .padding(24)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.gray.opacity(0.1) : Color.blue.opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Divider()
            
            // Content with animations
            ScrollView {
                VStack(spacing: 32) {
                    // Website Analysis Section
                    if let analysis = viewModel.analysisResult {
                        AnalysisSection(analysis: analysis)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if project.status == .analyzing {
                        AnalysisProgressView()
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        AnalysisPromptView {
                            Task {
                                await viewModel.analyzeWebsite(project.websiteURL)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Code Generation Section
                    if let code = viewModel.generatedCode {
                        CodeGenerationSection(code: code)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if project.status == .generating {
                        GenerationProgressView()
                            .transition(.scale.combined(with: .opacity))
                    } else if viewModel.analysisResult != nil {
                        GenerationPromptView {
                            Task {
                                await viewModel.generateiOSApp()
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Export Section
                    if project.status == .completed {
                        ExportSection(project: project, code: viewModel.generatedCode)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateProgress = true
        }
        .animation(.easeInOut(duration: 0.5), value: project.status)
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

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct ProgressIndicatorView: View {
    let status: ProjectStatus
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(statusColor.opacity(0.2), lineWidth: 3)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .trim(from: 0, to: isAnimating ? 1 : 0)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(status.displayName)
                    .font(.headline)
                    .foregroundColor(statusColor)
                
                Text(statusDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .analyzing: return .blue
        case .generating: return .orange
        default: return .gray
        }
    }
    
    private var statusDescription: String {
        switch status {
        case .analyzing: return "Analyzing website structure and content..."
        case .generating: return "Generating iOS app code with AI..."
        default: return ""
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
    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: isAnimating ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                
                Image(systemName: "magnifyingglass")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Analyzing Website")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Extracting content, structure, and design elements...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            isAnimating = true
        }
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
    @State private var selectedFileIndex = 0
    @State private var showingCodeView = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Generated iOS App", icon: "iphone")
            
            VStack(spacing: 16) {
                // Project info card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project: \(code.projectName)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Bundle ID: \(code.bundleIdentifier)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(code.swiftFiles.count) files")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("Swift files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !code.dependencies.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dependencies")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(code.dependencies, id: \.name) { dependency in
                                    DependencyCard(dependency: dependency)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                // File browser
                VStack(alignment: .leading, spacing: 12) {
                    Text("Generated Files")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(code.swiftFiles.enumerated()), id: \.offset) { index, file in
                                FileTabView(
                                    file: file,
                                    isSelected: selectedFileIndex == index,
                                    onTap: { selectedFileIndex = index }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Code preview
                    if !code.swiftFiles.isEmpty {
                        CodePreviewView(
                            file: code.swiftFiles[selectedFileIndex],
                            onViewFullCode: { showingCodeView = true }
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
        }
        .sheet(isPresented: $showingCodeView) {
            if !code.swiftFiles.isEmpty {
                FullCodeView(file: code.swiftFiles[selectedFileIndex])
            }
        }
    }
}

struct DependencyCard: View {
    let dependency: Dependency
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.caption)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(dependency.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(dependency.version)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
        )
    }
}

struct FileTabView: View {
    let file: SwiftFile
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(file.fileName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(NSColor.controlBackgroundColor))
            )
        }
        .buttonStyle(.plain)
    }
}

struct CodePreviewView: View {
    let file: SwiftFile
    let onViewFullCode: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(file.fileName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View Full Code") {
                    onViewFullCode()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            ScrollView {
                Text(file.content)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(maxHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
            )
        }
    }
}

struct FullCodeView: View {
    let file: SwiftFile
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.fileName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(file.content.components(separatedBy: .newlines).count) lines")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: copyCode) {
                        HStack {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            Text(copied ? "Copied!" : "Copy")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(copied)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Code content
                ScrollView {
                    Text(file.content)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(NSColor.textBackgroundColor))
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(file.content, forType: .string)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            copied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                copied = false
            }
        }
    }
}

struct GenerationProgressView: View {
    @State private var isAnimating = false
    @State private var currentStep = 0
    @Environment(\.colorScheme) private var colorScheme
    
    let steps = [
        "Analyzing website structure",
        "Generating SwiftUI views",
        "Creating navigation flow",
        "Adding native components",
        "Finalizing project files"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: isAnimating ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                
                Image(systemName: "gear")
                    .font(.title)
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            VStack(spacing: 8) {
                Text("Generating iOS App")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("AI is creating your native iOS app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Step indicator
            VStack(spacing: 12) {
                ForEach(0..<steps.count, id: \.self) { index in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(index <= currentStep ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 20, height: 20)
                            
                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            } else if index == currentStep {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true),
                                        value: isAnimating
                                    )
                            }
                        }
                        
                        Text(steps[index])
                            .font(.subheadline)
                            .foregroundColor(index <= currentStep ? .primary : .secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            isAnimating = true
            startStepAnimation()
        }
    }
    
    private func startStepAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if currentStep < steps.count - 1 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep += 1
                }
            } else {
                timer.invalidate()
            }
        }
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