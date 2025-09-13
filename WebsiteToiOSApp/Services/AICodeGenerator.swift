import Foundation

struct GeneratedCode: Codable {
    let projectName: String
    let bundleIdentifier: String
    let swiftFiles: [SwiftFile]
    let storyboardFiles: [StoryboardFile]
    let assetFiles: [AssetFile]
    let configurationFiles: [ConfigurationFile]
    let dependencies: [Dependency]
    let createdAt: Date
    
    init(projectName: String, bundleIdentifier: String) {
        self.projectName = projectName
        self.bundleIdentifier = bundleIdentifier
        self.swiftFiles = []
        self.storyboardFiles = []
        self.assetFiles = []
        self.configurationFiles = []
        self.dependencies = []
        self.createdAt = Date()
    }
}

struct SwiftFile: Codable {
    let fileName: String
    let content: String
    let target: FileTarget
}

struct StoryboardFile: Codable {
    let fileName: String
    let content: String
}

struct AssetFile: Codable {
    let fileName: String
    let data: Data
    let type: AssetType
}

struct ConfigurationFile: Codable {
    let fileName: String
    let content: String
    let type: ConfigurationType
}

struct Dependency: Codable {
    let name: String
    let version: String
    let source: DependencySource
}

enum FileTarget: String, Codable {
    case main = "main"
    case test = "test"
    case uiTest = "ui_test"
}

enum AssetType: String, Codable {
    case image = "image"
    case font = "font"
    case color = "color"
    case data = "data"
}

enum ConfigurationType: String, Codable {
    case infoPlist = "info_plist"
    case entitlements = "entitlements"
    case project = "project"
    case podfile = "podfile"
    case packageSwift = "package_swift"
}

enum DependencySource: String, Codable {
    case cocoapods = "cocoapods"
    case spm = "spm"
    case carthage = "carthage"
}

class AICodeGenerator {
    private let openAIService: OpenAIService
    private let ollamaService: OllamaService
    
    init() {
        self.openAIService = OpenAIService()
        self.ollamaService = OllamaService()
    }
    
    func generateiOSApp(project: Project, analysis: WebsiteAnalysis) async throws -> GeneratedCode {
        let prompt = createGenerationPrompt(project: project, analysis: analysis)
        
        let generatedCode: String
        switch project.aiModel {
        case .openAI:
            generatedCode = try await openAIService.generateCode(prompt: prompt)
        case .ollama:
            generatedCode = try await ollamaService.generateCode(prompt: prompt)
        }
        
        return try parseGeneratedCode(generatedCode, project: project)
    }
    
    private func createGenerationPrompt(project: Project, analysis: WebsiteAnalysis) -> String {
        return """
        Generate a complete iOS app for the following website analysis:
        
        Website: \(analysis.url)
        Title: \(analysis.title)
        Description: \(analysis.description ?? "No description")
        
        Project Requirements:
        - App Name: \(project.customizations.appName ?? analysis.title)
        - Bundle ID: \(project.customizations.bundleIdentifier ?? "com.\(analysis.title.lowercased().replacingOccurrences(of: " ", with: "")).app")
        - Target Devices: \(project.customizations.targetDevices.map { $0.rawValue }.joined(separator: ", "))
        - iOS Version: \(project.customizations.minimumiOSVersion)
        - Features: \(project.customizations.includeFeatures.map { $0.rawValue }.joined(separator: ", "))
        
        Website Structure:
        - Layout: \(analysis.structure.layout.rawValue)
        - Main Sections: \(analysis.structure.mainSections.count)
        - Navigation: \(analysis.navigation.mainMenu.count) menu items
        - Forms: \(analysis.forms.count)
        - Images: \(analysis.images.count)
        
        Style Analysis:
        - Primary Colors: \(analysis.styles.primaryColors.joined(separator: ", "))
        - Fonts: \(analysis.styles.fonts.map { $0.family }.joined(separator: ", "))
        
        Generate a complete iOS project with:
        1. SwiftUI views that replicate the website structure
        2. Navigation between sections
        3. WebView integration for dynamic content
        4. Native iOS components where appropriate
        5. Proper styling and theming
        6. All necessary configuration files
        
        Return the code in a structured format that can be parsed into individual files.
        """
    }
    
    private func parseGeneratedCode(_ code: String, project: Project) throws -> GeneratedCode {
        // This would parse the AI-generated code into structured file objects
        // For now, return a basic structure with template files
        
        let bundleIdentifier = project.customizations.bundleIdentifier ?? "com.\(project.name.lowercased().replacingOccurrences(of: " ", with: "")).app"
        
        var generatedCode = GeneratedCode(
            projectName: project.name,
            bundleIdentifier: bundleIdentifier
        )
        
        // Generate main app file
        let appFile = SwiftFile(
            fileName: "\(project.name)App.swift",
            content: generateAppFile(project: project),
            target: .main
        )
        
        // Generate main content view
        let contentViewFile = SwiftFile(
            fileName: "ContentView.swift",
            content: generateContentView(project: project),
            target: .main
        )
        
        // Generate web view component
        let webViewFile = SwiftFile(
            fileName: "WebViewComponent.swift",
            content: generateWebViewComponent(),
            target: .main
        )
        
        // Generate navigation view
        let navigationFile = SwiftFile(
            fileName: "NavigationView.swift",
            content: generateNavigationView(),
            target: .main
        )
        
        // Generate Info.plist
        let infoPlistFile = ConfigurationFile(
            fileName: "Info.plist",
            content: generateInfoPlist(project: project),
            type: .infoPlist
        )
        
        // Generate project file
        let projectFile = ConfigurationFile(
            fileName: "\(project.name).xcodeproj/project.pbxproj",
            content: generateProjectFile(project: project),
            type: .project
        )
        
        generatedCode.swiftFiles = [appFile, contentViewFile, webViewFile, navigationFile]
        generatedCode.configurationFiles = [infoPlistFile, projectFile]
        generatedCode.dependencies = [
            Dependency(name: "Alamofire", version: "5.8.0", source: .spm),
            Dependency(name: "SDWebImageSwiftUI", version: "2.3.0", source: .spm)
        ]
        
        return generatedCode
    }
    
    private func generateAppFile(project: Project) -> String {
        return """
        import SwiftUI

        @main
        struct \(project.name.replacingOccurrences(of: " ", with: ""))App: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }
        """
    }
    
    private func generateContentView(project: Project) -> String {
        return """
        import SwiftUI

        struct ContentView: View {
            @StateObject private var viewModel = WebsiteViewModel()
            
            var body: some View {
                NavigationView {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            WebViewComponent(url: viewModel.websiteURL)
                        }
                    }
                    .navigationTitle("\(project.name)")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }

        #Preview {
            ContentView()
        }
        """
    }
    
    private func generateWebViewComponent() -> String {
        return """
        import SwiftUI
        import WebKit

        struct WebViewComponent: UIViewRepresentable {
            let url: String
            
            func makeUIView(context: Context) -> WKWebView {
                let webView = WKWebView()
                webView.navigationDelegate = context.coordinator
                return webView
            }
            
            func updateUIView(_ webView: WKWebView, context: Context) {
                guard let url = URL(string: url) else { return }
                let request = URLRequest(url: url)
                webView.load(request)
            }
            
            func makeCoordinator() -> Coordinator {
                Coordinator()
            }
            
            class Coordinator: NSObject, WKNavigationDelegate {
                func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    // Handle navigation completion
                }
            }
        }
        """
    }
    
    private func generateNavigationView() -> String {
        return """
        import SwiftUI

        struct NavigationView: View {
            let menuItems: [MenuItem]
            
            var body: some View {
                List(menuItems) { item in
                    NavigationLink(destination: WebViewComponent(url: item.url)) {
                        Text(item.text)
                    }
                }
                .navigationTitle("Menu")
            }
        }

        struct MenuItem: Identifiable {
            let id = UUID()
            let text: String
            let url: String
        }
        """
    }
    
    private func generateInfoPlist(project: Project) -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>$(DEVELOPMENT_LANGUAGE)</string>
            <key>CFBundleDisplayName</key>
            <string>\(project.name)</string>
            <key>CFBundleExecutable</key>
            <string>$(EXECUTABLE_NAME)</string>
            <key>CFBundleIdentifier</key>
            <string>\(project.customizations.bundleIdentifier ?? "com.\(project.name.lowercased().replacingOccurrences(of: " ", with: "")).app")</string>
            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>
            <key>CFBundleName</key>
            <string>$(PRODUCT_NAME)</string>
            <key>CFBundlePackageType</key>
            <string>APPL</string>
            <key>CFBundleShortVersionString</key>
            <string>1.0</string>
            <key>CFBundleVersion</key>
            <string>1</string>
            <key>LSRequiresIPhoneOS</key>
            <true/>
            <key>UIApplicationSceneManifest</key>
            <dict>
                <key>UIApplicationSupportsMultipleScenes</key>
                <true/>
            </dict>
            <key>UILaunchScreen</key>
            <dict/>
            <key>UIRequiredDeviceCapabilities</key>
            <array>
                <string>armv7</string>
            </array>
            <key>UISupportedInterfaceOrientations</key>
            <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
            </array>
            <key>UISupportedInterfaceOrientations~ipad</key>
            <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationPortraitUpsideDown</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
            </array>
        </dict>
        </plist>
        """
    }
    
    private func generateProjectFile(project: Project) -> String {
        // This would generate a complete Xcode project file
        // For brevity, returning a simplified version
        return """
        // !$*UTF8*$!
        {
            // Xcode project file content would go here
            // This is a simplified version for demonstration
        }
        """
    }
}