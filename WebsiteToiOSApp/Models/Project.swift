import Foundation

struct Project: Identifiable, Codable {
    let id = UUID()
    var name: String
    var websiteURL: String
    var createdAt: Date
    var lastModified: Date
    var status: ProjectStatus
    var aiModel: AIModel
    var customizations: ProjectCustomizations
    
    init(name: String, websiteURL: String, aiModel: AIModel = .openAI) {
        self.name = name
        self.websiteURL = websiteURL
        self.createdAt = Date()
        self.lastModified = Date()
        self.status = .draft
        self.aiModel = aiModel
        self.customizations = ProjectCustomizations()
    }
}

enum ProjectStatus: String, CaseIterable, Codable {
    case draft = "draft"
    case analyzing = "analyzing"
    case generating = "generating"
    case completed = "completed"
    case error = "error"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .analyzing: return "Analyzing Website"
        case .generating: return "Generating iOS App"
        case .completed: return "Completed"
        case .error: return "Error"
        }
    }
    
    var systemImage: String {
        switch self {
        case .draft: return "doc.text"
        case .analyzing: return "magnifyingglass"
        case .generating: return "gear"
        case .completed: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

enum AIModel: String, CaseIterable, Codable {
    case openAI = "openai"
    case ollama = "ollama"
    
    var displayName: String {
        switch self {
        case .openAI: return "OpenAI GPT-4"
        case .ollama: return "Ollama (Local)"
        }
    }
    
    var description: String {
        switch self {
        case .openAI: return "Cloud-based AI with latest models"
        case .ollama: return "Local AI processing for privacy"
        }
    }
}

struct ProjectCustomizations: Codable {
    var appName: String?
    var bundleIdentifier: String?
    var targetDevices: [TargetDevice]
    var minimumiOSVersion: String
    var includeFeatures: [AppFeature]
    var customStyling: CustomStyling?
    
    init() {
        self.targetDevices = [.iphone, .ipad]
        self.minimumiOSVersion = "15.0"
        self.includeFeatures = [.navigation, .webView, .nativeComponents]
    }
}

enum TargetDevice: String, CaseIterable, Codable {
    case iphone = "iphone"
    case ipad = "ipad"
    
    var displayName: String {
        switch self {
        case .iphone: return "iPhone"
        case .ipad: return "iPad"
        }
    }
}

enum AppFeature: String, CaseIterable, Codable {
    case navigation = "navigation"
    case webView = "webview"
    case nativeComponents = "native_components"
    case pushNotifications = "push_notifications"
    case offlineSupport = "offline_support"
    case biometricAuth = "biometric_auth"
    case deepLinking = "deep_linking"
    
    var displayName: String {
        switch self {
        case .navigation: return "Native Navigation"
        case .webView: return "WebView Integration"
        case .nativeComponents: return "Native UI Components"
        case .pushNotifications: return "Push Notifications"
        case .offlineSupport: return "Offline Support"
        case .biometricAuth: return "Biometric Authentication"
        case .deepLinking: return "Deep Linking"
        }
    }
}

struct CustomStyling: Codable {
    var primaryColor: String?
    var secondaryColor: String?
    var fontFamily: String?
    var cornerRadius: Double?
    var shadowStyle: String?
}