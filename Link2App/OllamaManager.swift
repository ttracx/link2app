import Foundation

@MainActor
class OllamaManager: ObservableObject {
    @Published var isConnected = false
    @Published var connectionStatus = ""
    @Published var selectedModel = "llama2"
    @Published var availableModels: [String] = []
    
    private var endpoint = "http://localhost:11434"
    
    func setEndpoint(_ endpoint: String) {
        self.endpoint = endpoint
        connectionStatus = ""
    }
    
    func testConnection() {
        Task {
            do {
                let url = URL(string: "\(endpoint)/api/tags")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
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
    
    func fetchAvailableModels() {
        Task {
            do {
                let url = URL(string: "\(endpoint)/api/tags")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let models = json["models"] as? [[String: Any]] {
                    let modelNames = models.compactMap { $0["name"] as? String }
                    
                    await MainActor.run {
                        availableModels = modelNames
                        if !modelNames.isEmpty && selectedModel.isEmpty {
                            selectedModel = modelNames.first ?? "llama2"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    availableModels = []
                    print("Error fetching models: \(error)")
                }
            }
        }
    }
    
    func generateCode(prompt: String) async throws -> String {
        guard !endpoint.isEmpty else {
            throw OllamaError.noEndpoint
        }
        
        let url = URL(string: "\(endpoint)/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = """
        You are an expert iOS SwiftUI developer. Generate clean, modern, and functional SwiftUI code. 
        Always include proper imports and structure. Make the code production-ready with proper error handling and best practices.
        Focus on creating native iOS experiences that are optimized for both iPhone and iPad.
        """
        
        let fullPrompt = systemPrompt + "\n\nUser Request: " + prompt
        
        let requestBody: [String: Any] = [
            "model": selectedModel,
            "prompt": fullPrompt,
            "stream": false,
            "options": [
                "temperature": 0.7,
                "num_predict": 4000
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OllamaError.apiError(errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OllamaError.invalidResponse
        }
        
        return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func generateCodeStream(prompt: String) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard !endpoint.isEmpty else {
                        throw OllamaError.noEndpoint
                    }
                    
                    let url = URL(string: "\(endpoint)/api/generate")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let systemPrompt = """
                    You are an expert iOS SwiftUI developer. Generate clean, modern, and functional SwiftUI code. 
                    Always include proper imports and structure. Make the code production-ready with proper error handling and best practices.
                    Focus on creating native iOS experiences that are optimized for both iPhone and iPad.
                    """
                    
                    let fullPrompt = systemPrompt + "\n\nUser Request: " + prompt
                    
                    let requestBody: [String: Any] = [
                        "model": selectedModel,
                        "prompt": fullPrompt,
                        "stream": true,
                        "options": [
                            "temperature": 0.7,
                            "num_predict": 4000
                        ]
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        throw OllamaError.apiError("HTTP \(httpResponse.statusCode)")
                    }
                    
                    for try await line in bytes.lines {
                        if let data = line.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let response = json["response"] as? String {
                            continuation.yield(response)
                            
                            if let done = json["done"] as? Bool, done {
                                continuation.finish()
                                return
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

enum OllamaError: LocalizedError {
    case noEndpoint
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noEndpoint:
            return "Ollama endpoint is required"
        case .apiError(let message):
            return "Ollama API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from Ollama API"
        }
    }
}