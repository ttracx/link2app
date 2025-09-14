import Foundation
import SwiftUI
import Combine

@MainActor
class WebsiteConversionViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var selectedProject: Project?
    @Published var isAnalyzing = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var analysisResult: WebsiteAnalysis?
    @Published var generatedCode: GeneratedCode?
    
    private let webAnalyzer = WebsiteAnalyzer()
    private let codeGenerator = AICodeGenerator()
    private var cancellables = Set<AnyCancellable>()
    
    var recentProjects: [Project] {
        projects.sorted { $0.lastModified > $1.lastModified }.prefix(5).map { $0 }
    }
    
    init() {
        loadProjects()
    }
    
    func createNewProject() {
        let newProject = Project(name: "New Project", websiteURL: "")
        projects.append(newProject)
        selectedProject = newProject
        saveProjects()
    }
    
    func validateURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              (scheme == "http" || scheme == "https") else {
            return false
        }
        return true
    }
    
    func selectProject(_ project: Project) {
        selectedProject = project
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            selectedProject = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        if selectedProject?.id == project.id {
            selectedProject = nil
        }
        saveProjects()
    }
    
    func analyzeWebsite(_ url: String) async {
        guard !url.isEmpty else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        do {
            let analysis = try await webAnalyzer.analyzeWebsite(url: url)
            analysisResult = analysis
            
            // Update project with analysis results
            if var project = selectedProject {
                project.status = .analyzing
                project.lastModified = Date()
                updateProject(project)
            }
        } catch {
            errorMessage = "Failed to analyze website: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
    
    func generateiOSApp() async {
        guard let project = selectedProject,
              let analysis = analysisResult else { return }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            let code = try await codeGenerator.generateiOSApp(
                project: project,
                analysis: analysis
            )
            generatedCode = code
            
            // Update project status
            var updatedProject = project
            updatedProject.status = .completed
            updatedProject.lastModified = Date()
            updateProject(updatedProject)
            
        } catch {
            errorMessage = "Failed to generate iOS app: \(error.localizedDescription)"
            
            // Update project status to error
            var updatedProject = project
            updatedProject.status = .error
            updatedProject.lastModified = Date()
            updateProject(updatedProject)
        }
        
        isGenerating = false
    }
    
    func exportProject() {
        guard let project = selectedProject,
              let code = generatedCode else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose Export Location"
        panel.message = "Choose where to save the iOS project"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                Task { @MainActor in
                    await self.performExport(to: url, project: project, code: code)
                }
            }
        }
    }
    
    @MainActor
    private func performExport(to url: URL, project: Project, code: GeneratedCode) async {
        do {
            let projectURL = url.appendingPathComponent(code.projectName)
            try FileManager.default.createDirectory(at: projectURL, withIntermediateDirectories: true)
            
            // Create Xcode project directory
            let xcodeProjectURL = projectURL.appendingPathComponent("\(code.projectName).xcodeproj")
            try FileManager.default.createDirectory(at: xcodeProjectURL, withIntermediateDirectories: true)
            
            // Write Swift files
            for swiftFile in code.swiftFiles {
                let fileURL = projectURL.appendingPathComponent(swiftFile.fileName)
                try swiftFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Write configuration files
            for configFile in code.configurationFiles {
                let fileURL = projectURL.appendingPathComponent(configFile.fileName)
                try configFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Create Package.swift if there are dependencies
            if !code.dependencies.isEmpty {
                let packageSwift = generatePackageSwift(dependencies: code.dependencies)
                let packageURL = projectURL.appendingPathComponent("Package.swift")
                try packageSwift.write(to: packageURL, atomically: true, encoding: .utf8)
            }
            
            // Show success message
            let alert = NSAlert()
            alert.messageText = "Export Successful"
            alert.informativeText = "iOS project exported to: \(projectURL.path)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Open in Finder")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                NSWorkspace.shared.open(projectURL)
            }
            
        } catch {
            errorMessage = "Failed to export project: \(error.localizedDescription)"
        }
    }
    
    private func generatePackageSwift(dependencies: [Dependency]) -> String {
        var packageContent = """
        // swift-tools-version: 5.9
        import PackageDescription

        let package = Package(
            name: "\(generatedCode?.projectName ?? "iOSApp")",
            platforms: [
                .iOS(.v15)
            ],
            products: [
                .library(
                    name: "\(generatedCode?.projectName ?? "iOSApp")",
                    targets: ["\(generatedCode?.projectName ?? "iOSApp")"]
                ),
            ],
            dependencies: [
        """
        
        for dependency in dependencies {
            switch dependency.source {
            case .spm:
                packageContent += """
                    .package(url: "https://github.com/\(dependency.name)/\(dependency.name).git", from: "\(dependency.version)"),
                """
            case .cocoapods:
                // CocoaPods dependencies would be handled separately
                break
            case .carthage:
                // Carthage dependencies would be handled separately
                break
            }
        }
        
        packageContent += """
            ],
            targets: [
                .target(
                    name: "\(generatedCode?.projectName ?? "iOSApp")",
                    dependencies: [
        """
        
        for dependency in dependencies {
            packageContent += """
                        "\(dependency.name)",
            """
        }
        
        packageContent += """
                    ]
                ),
            ]
        )
        """
        
        return packageContent
    }
    
    private func loadProjects() {
        // Load projects from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "projects"),
           let projects = try? JSONDecoder().decode([Project].self, from: data) {
            self.projects = projects
        }
    }
    
    private func saveProjects() {
        // Save projects to UserDefaults or Core Data
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: "projects")
        }
    }
}