import SwiftUI

@main
struct Link2AppApp: App {
    @StateObject private var aiManager = AIManager()
    @StateObject private var ollamaManager = OllamaManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(aiManager)
                .environmentObject(ollamaManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .environmentObject(aiManager)
                .environmentObject(ollamaManager)
        }
    }
}