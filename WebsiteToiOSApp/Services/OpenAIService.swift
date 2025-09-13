import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    init() {
        // Load API key from UserDefaults or Keychain
        self.apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    func generateCode(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIServiceError.missingAPIKey
        }
        
        let request = createRequest(prompt: prompt)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content ?? ""
    }
    
    private func createRequest(prompt: String) -> URLRequest {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-4",
            messages: [
                OpenAIMessage(role: "system", content: "You are an expert iOS developer. Generate complete, production-ready Swift code for iOS apps."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 4000,
            temperature: 0.7
        )
        
        request.httpBody = try? JSONEncoder().encode(requestBody)
        return request
    }
    
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }
    
    func validateAPIKey() async throws -> Bool {
        let request = createRequest(prompt: "Test")
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        return false
    }
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

enum AIServiceError: Error, LocalizedError {
    case missingAPIKey
    case requestFailed
    case invalidResponse
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please set it in settings."
        case .requestFailed:
            return "Failed to make request to OpenAI API"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        }
    }
}