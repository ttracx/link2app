import Foundation
import WebKit

@MainActor
class WebsiteConverter: ObservableObject {
    @Published var isLoading = false
    @Published var websiteContent = ""
    @Published var websiteTitle = ""
    
    private var webView: WKWebView?
    
    init() {
        setupWebView()
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView?.navigationDelegate = WebViewNavigationDelegate()
    }
    
    func loadWebsite(url: String) {
        guard let webView = webView,
              let url = URL(string: url) else { return }
        
        isLoading = true
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func extractContent() async -> String {
        guard let webView = webView else { return "" }
        
        let script = """
        function extractPageContent() {
            const title = document.title;
            const description = document.querySelector('meta[name="description"]')?.content || '';
            const headings = Array.from(document.querySelectorAll('h1, h2, h3')).map(h => h.textContent).join(' | ');
            const mainContent = document.body.innerText.slice(0, 2000);
            const images = Array.from(document.querySelectorAll('img')).map(img => img.src).slice(0, 5);
            const links = Array.from(document.querySelectorAll('a')).map(a => ({text: a.textContent, href: a.href})).slice(0, 10);
            
            return {
                title: title,
                description: description,
                headings: headings,
                content: mainContent,
                images: images,
                links: links
            };
        }
        
        extractPageContent();
        """
        
        do {
            let result = try await webView.evaluateJavaScript(script)
            if let contentDict = result as? [String: Any] {
                return formatExtractedContent(contentDict)
            }
        } catch {
            print("Error extracting content: \(error)")
        }
        
        return ""
    }
    
    private func formatExtractedContent(_ content: [String: Any]) -> String {
        var formatted = ""
        
        if let title = content["title"] as? String {
            formatted += "Title: \(title)\n\n"
        }
        
        if let description = content["description"] as? String, !description.isEmpty {
            formatted += "Description: \(description)\n\n"
        }
        
        if let headings = content["headings"] as? String, !headings.isEmpty {
            formatted += "Headings: \(headings)\n\n"
        }
        
        if let mainContent = content["content"] as? String {
            formatted += "Content: \(mainContent)\n\n"
        }
        
        if let images = content["images"] as? [String], !images.isEmpty {
            formatted += "Images: \(images.joined(separator: ", "))\n\n"
        }
        
        if let links = content["links"] as? [[String: Any]], !links.isEmpty {
            formatted += "Links:\n"
            for link in links {
                if let text = link["text"] as? String,
                   let href = link["href"] as? String {
                    formatted += "- \(text): \(href)\n"
                }
            }
            formatted += "\n"
        }
        
        return formatted
    }
    
    func exportProject(code: String, to url: URL) {
        do {
            // Create project directory structure
            let projectURL = url.appendingPathComponent("MyiOSApp")
            try FileManager.default.createDirectory(at: projectURL, withIntermediateDirectories: true)
            
            // Create main Swift file
            let mainFileURL = projectURL.appendingPathComponent("ContentView.swift")
            try code.write(to: mainFileURL, atomically: true, encoding: .utf8)
            
            // Create App file
            let appCode = generateAppFile()
            let appFileURL = projectURL.appendingPathComponent("App.swift")
            try appCode.write(to: appFileURL, atomically: true, encoding: .utf8)
            
            // Create Package.swift
            let packageCode = generatePackageFile()
            let packageFileURL = projectURL.appendingPathComponent("Package.swift")
            try packageCode.write(to: packageFileURL, atomically: true, encoding: .utf8)
            
            // Create README
            let readmeCode = generateReadme()
            let readmeFileURL = projectURL.appendingPathComponent("README.md")
            try readmeCode.write(to: readmeFileURL, atomically: true, encoding: .utf8)
            
            // Create .gitignore
            let gitignoreCode = generateGitignore()
            let gitignoreFileURL = projectURL.appendingPathComponent(".gitignore")
            try gitignoreCode.write(to: gitignoreFileURL, atomically: true, encoding: .utf8)
            
            // Open the created folder
            NSWorkspace.shared.open(projectURL)
            
        } catch {
            print("Error exporting project: \(error)")
        }
    }
    
    private func generateAppFile() -> String {
        return """
        import SwiftUI
        
        @main
        struct MyiOSApp: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }
        """
    }
    
    private func generatePackageFile() -> String {
        return """
        // swift-tools-version: 5.9
        import PackageDescription
        
        let package = Package(
            name: "MyiOSApp",
            platforms: [
                .iOS(.v17),
                .macOS(.v14)
            ],
            products: [
                .executable(name: "MyiOSApp", targets: ["MyiOSApp"])
            ],
            targets: [
                .executableTarget(
                    name: "MyiOSApp",
                    dependencies: []
                )
            ]
        )
        """
    }
    
    private func generateReadme() -> String {
        return """
        # MyiOSApp
        
        Generated by Link2App - Convert any website into an iOS app
        
        ## Features
        - Native iOS SwiftUI interface
        - Responsive design for iPhone and iPad
        - Generated from website content using AI
        
        ## Requirements
        - iOS 17.0+
        - Xcode 15.0+
        
        ## Installation
        1. Open the project in Xcode
        2. Select your target device or simulator
        3. Run the project (⌘+R)
        
        ## Generated with Link2App
        This project was automatically generated from a website using AI-powered code generation.
        Visit [Link2App](https://github.com/ttracx/link2app) for more information.
        """
    }
    
    private func generateGitignore() -> String {
        return """
        # Xcode
        *.xcodeproj/*
        !*.xcodeproj/project.pbxproj
        !*.xcodeproj/xcshareddata/
        !*.xcodeproj/project.xcworkspace/
        *.xcworkspace/*
        !*.xcworkspace/contents.xcworkspacedata
        
        # Build generated
        build/
        DerivedData/
        
        # Various settings
        *.pbxuser
        !default.pbxuser
        *.mode1v3
        !default.mode1v3
        *.mode2v3
        !default.mode2v3
        *.perspectivev3
        !default.perspectivev3
        xcuserdata/
        
        # Swift Package Manager
        .build/
        
        # CocoaPods
        Pods/
        
        # macOS
        .DS_Store
        """
    }
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Website finished loading
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load website: \(error)")
    }
}