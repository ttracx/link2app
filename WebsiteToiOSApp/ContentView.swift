import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WebsiteConversionViewModel()
    @State private var showingSettings = false
    @State private var showingProjectEdit = false
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel, searchText: $searchText)
        } detail: {
            MainConversionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingProjectEdit) {
            if let project = viewModel.selectedProject {
                ProjectEditView(project: project, viewModel: viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    if viewModel.selectedProject != nil {
                        Button(action: { showingProjectEdit = true }) {
                            Label("Edit Project", systemImage: "pencil")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color.black : Color.white,
                    colorScheme == .dark ? Color.gray.opacity(0.1) : Color.blue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct SidebarView: View {
    @ObservedObject var viewModel: WebsiteConversionViewModel
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme
    
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return viewModel.recentProjects
        } else {
            return viewModel.recentProjects.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.websiteURL.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "globe.americas.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Website to iOS")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search projects...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Divider()
            
            // Projects section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Recent Projects")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Text("\(filteredProjects.count) found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if filteredProjects.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: searchText.isEmpty ? "folder" : "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "No recent projects" : "No projects found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Text("Create your first project to get started")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredProjects) { project in
                                ProjectCardView(project: project) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.selectProject(project)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: { viewModel.createNewProject() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Project")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: { /* TODO: Implement project import */ }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Project")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .frame(minWidth: 280)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

struct ProjectCardView: View {
    let project: Project
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(project.websiteURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    StatusIndicator(status: project.status)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Created")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(project.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("AI Model")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(project.aiModel.displayName)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        project.status == .completed ? Color.green.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: project.status)
    }
}

struct StatusIndicator: View {
    let status: ProjectStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status.displayName)
                .font(.caption2)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
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

struct MainConversionView: View {
    @ObservedObject var viewModel: WebsiteConversionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let selectedProject = viewModel.selectedProject {
                ProjectDetailView(project: selectedProject, viewModel: viewModel)
            } else {
                WelcomeView()
            }
        }
    }
}

struct WelcomeView: View {
    @State private var isAnimating = false
    @State private var showFeatures = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Hero section
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.2),
                                        Color.purple.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Transform Websites into iOS Apps")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Convert any website into a native iOS app with AI-powered code generation. Create beautiful, performant apps that feel truly native.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 60)
                
                // Features section
                VStack(spacing: 20) {
                    Text("Why Choose Our Platform?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .opacity(showFeatures ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.2), value: showFeatures)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        FeatureCard(
                            icon: "sparkles",
                            title: "AI-Powered Conversion",
                            description: "Uses OpenAI and Ollama for intelligent code generation",
                            color: .blue,
                            delay: 0.3
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: showFeatures)
                        
                        FeatureCard(
                            icon: "iphone",
                            title: "Native iOS Experience",
                            description: "Creates true native iOS apps, not web wrappers",
                            color: .green,
                            delay: 0.4
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: showFeatures)
                        
                        FeatureCard(
                            icon: "gear",
                            title: "Customizable",
                            description: "Fine-tune the conversion with advanced settings",
                            color: .orange,
                            delay: 0.5
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: showFeatures)
                        
                        FeatureCard(
                            icon: "bolt.fill",
                            title: "Fast & Efficient",
                            description: "Generate complete iOS projects in minutes",
                            color: .purple,
                            delay: 0.6
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: showFeatures)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Call to action
                VStack(spacing: 16) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Your First Project")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(showFeatures ? 1.0 : 0.9)
                    .opacity(showFeatures ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: showFeatures)
                    
                    Text("Start building your iOS app in minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(showFeatures ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(1.0), value: showFeatures)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showFeatures = true
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
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


#Preview {
    ContentView()
}