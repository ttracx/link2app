import Foundation

@MainActor
class AIManager: ObservableObject {
    @Published var isConnected = false
    @Published var connectionStatus = ""
    @Published var selectedModel = "gpt-4"
    
    private var apiKey = ""
    private let baseURL = "https://api.openai.com/v1"
    
    func setAPIKey(_ key: String) {
        apiKey = key
        connectionStatus = ""
    }
    
    func testConnection() {
        guard !apiKey.isEmpty else {
            connectionStatus = "API key is required"
            isConnected = false
            return
        }
        
        Task {
            do {
                let url = URL(string: "\(baseURL)/models")!
                var request = URLRequest(url: url)
                request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        if httpResponse.statusCode == 200 {
                            isConnected = true
                            connectionStatus = "Connected successfully"
                        } else {
                            isConnected = false
                            connectionStatus = "Connection failed: \(httpResponse.statusCode)"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isConnected = false
                    connectionStatus = "Connection error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func generateCode(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": [
                [
                    "role": "system",
                    "content": "You are an expert iOS SwiftUI developer. Generate clean, modern, and functional SwiftUI code. Always include proper imports and structure. Make the code production-ready with proper error handling and best practices."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 4000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError(errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum AIError: LocalizedError {
    case noAPIKey
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key is required"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        }
    }
}