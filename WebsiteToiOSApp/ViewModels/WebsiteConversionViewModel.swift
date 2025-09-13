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
        
        // Implementation for exporting the generated iOS project
        // This would create the Xcode project files and save them
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