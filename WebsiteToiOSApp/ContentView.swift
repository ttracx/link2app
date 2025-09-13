import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WebsiteConversionViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } detail: {
            MainConversionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Settings") {
                    showingSettings = true
                }
            }
        }
    }
}

struct SidebarView: View {
    @ObservedObject var viewModel: WebsiteConversionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Website to iOS")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Projects")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if viewModel.recentProjects.isEmpty {
                    Text("No recent projects")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(viewModel.recentProjects) { project in
                        ProjectRowView(project: project) {
                            viewModel.selectProject(project)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button("New Project") {
                viewModel.createNewProject()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .frame(minWidth: 250)
    }
}

struct ProjectRowView: View {
    let project: Project
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(project.websiteURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
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
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Transform Websites into iOS Apps")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Convert any website into a native iOS app with AI-powered code generation")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                FeatureRow(icon: "sparkles", title: "AI-Powered Conversion", description: "Uses OpenAI and Ollama for intelligent code generation")
                FeatureRow(icon: "iphone", title: "Native iOS Experience", description: "Creates true native iOS apps, not web wrappers")
                FeatureRow(icon: "gear", title: "Customizable", description: "Fine-tune the conversion with advanced settings")
            }
            .padding(.horizontal, 40)
            
            Button("Get Started") {
                // This will be handled by the parent view
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}