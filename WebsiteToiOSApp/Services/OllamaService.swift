import Foundation

class OllamaService {
    private let baseURL: String
    private let model: String
    
    init() {
        // Load Ollama configuration from UserDefaults
        self.baseURL = UserDefaults.standard.string(forKey: "ollama_base_url") ?? "http://localhost:11434"
        self.model = UserDefaults.standard.string(forKey: "ollama_model") ?? "llama2"
    }
    
    func generateCode(prompt: String) async throws -> String {
        let request = createRequest(prompt: prompt)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let ollamaResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return ollamaResponse.response
    }
    
    private func createRequest(prompt: String) -> URLRequest {
        let url = URL(string: "\(baseURL)/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OllamaRequest(
            model: model,
            prompt: "You are an expert iOS developer. Generate complete, production-ready Swift code for iOS apps.\n\n\(prompt)",
            stream: false,
            options: OllamaOptions(
                temperature: 0.7,
                topP: 0.9,
                maxTokens: 4000
            )
        )
        
        request.httpBody = try? JSONEncoder().encode(requestBody)
        return request
    }
    
    func setBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "ollama_base_url")
    }
    
    func setModel(_ model: String) {
        UserDefaults.standard.set(model, forKey: "ollama_model")
    }
    
    func getAvailableModels() async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/tags")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let modelsResponse = try JSONDecoder().decode(OllamaModelsResponse.self, from: data)
        return modelsResponse.models.map { $0.name }
    }
    
    func validateConnection() async throws -> Bool {
        let url = URL(string: "\(baseURL)/api/tags")!
        let (_, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        return false
    }
}

struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
    let options: OllamaOptions
}

struct OllamaOptions: Codable {
    let temperature: Double
    let topP: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case topP = "top_p"
        case maxTokens = "num_predict"
    }
}

struct OllamaResponse: Codable {
    let model: String
    let createdAt: String
    let response: String
    let done: Bool
    
    enum CodingKeys: String, CodingKey {
        case model, response, done
        case createdAt = "created_at"
    }
}

struct OllamaModelsResponse: Codable {
    let models: [OllamaModel]
}

struct OllamaModel: Codable {
    let name: String
    let modifiedAt: String
    let size: Int
    
    enum CodingKeys: String, CodingKey {
        case name, size
        case modifiedAt = "modified_at"
    }
}