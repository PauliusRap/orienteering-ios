import Foundation

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return message ?? "Server error (\(statusCode))"
        case .unauthorized:
            return "Please log in to continue"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

// MARK: - API Service
@MainActor
class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://orienteering-game.fly.dev"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let tokenKey = "auth_token"
    private let userKey = "cached_user"
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        // Check for existing token on init
        if let token = getStoredToken(), !token.isEmpty {
            self.isAuthenticated = true
            self.currentUser = getCachedUser()
        }
    }
    
    // MARK: - Token Management
    
    private func getStoredToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    private func storeToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    private func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    private func cacheUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    private func getCachedUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    // MARK: - Request Building
    
    private func buildRequest(endpoint: String, method: String = "GET", body: Data? = nil, requiresAuth: Bool = false) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth {
            guard let token = getStoredToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Generic Request Method
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            // Debug: Print response for troubleshooting
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Response [\(httpResponse.statusCode)]: \(jsonString)")
            }
            #endif
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                // Token expired or invalid
                await logout()
                throw APIError.unauthorized
            case 400...499:
                // Client error - try to extract message
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.message ?? errorResponse.error)
                }
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
            case 500...599:
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Server is temporarily unavailable")
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Auth Endpoints
    
    func register(username: String, email: String, password: String) async throws -> User {
        let body = try JSONSerialization.data(withJSONObject: [
            "username": username,
            "email": email,
            "password": password
        ])
        
        let request = try buildRequest(endpoint: "/api/auth/register", method: "POST", body: body)
        let user: User = try await performRequest(request)
        
        currentUser = user
        cacheUser(user)
        
        return user
    }
    
    func login(username: String, password: String) async throws -> User {
        let body = try JSONSerialization.data(withJSONObject: [
            "username": username,
            "password": password
        ])
        
        let request = try buildRequest(endpoint: "/api/auth/login", method: "POST", body: body)
        let response: LoginResponse = try await performRequest(request)
        
        storeToken(response.token)
        isAuthenticated = true
        
        // Fetch user profile after login
        let user = try await fetchProfile()
        currentUser = user
        cacheUser(user)
        
        return user
    }
    
    func logout() async {
        clearToken()
        isAuthenticated = false
        currentUser = nil
    }
    
    func fetchProfile() async throws -> User {
        let request = try buildRequest(endpoint: "/api/users/me", requiresAuth: true)
        let user: User = try await performRequest(request)
        currentUser = user
        cacheUser(user)
        return user
    }
    
    func updateProfile(username: String? = nil, email: String? = nil) async throws -> User {
        var bodyDict: [String: Any] = [:]
        if let username = username { bodyDict["username"] = username }
        if let email = email { bodyDict["email"] = email }
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        let request = try buildRequest(endpoint: "/api/users/me", method: "PUT", body: body, requiresAuth: true)
        let user: User = try await performRequest(request)
        currentUser = user
        cacheUser(user)
        return user
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws {
        let body = try JSONSerialization.data(withJSONObject: [
            "oldPassword": oldPassword,
            "newPassword": newPassword
        ])
        let request = try buildRequest(endpoint: "/api/users/me/password", method: "POST", body: body, requiresAuth: true)
        let _: EmptyResponse = try await performRequest(request)
    }
    
    // MARK: - Hunts Endpoints
    
    func fetchHunts(search: String? = nil, difficulty: HuntDifficulty? = nil) async throws -> [Hunt] {
        var endpoint = "/api/hunts"
        var queryItems: [String] = []
        
        if let search = search, !search.isEmpty {
            queryItems.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? search)")
        }
        
        if let difficulty = difficulty {
            queryItems.append("difficulty=\(difficulty.rawValue)")
        }
        
        if !queryItems.isEmpty {
            endpoint += "?" + queryItems.joined(separator: "&")
        }
        
        let request = try buildRequest(endpoint: endpoint)
        return try await performRequest(request)
    }
    
    func fetchHunt(id: String) async throws -> HuntDetail {
        let request = try buildRequest(endpoint: "/api/hunts/\(id)")
        return try await performRequest(request)
    }
    
    func startHunt(id: String) async throws -> HuntProgress {
        let request = try buildRequest(endpoint: "/api/hunts/\(id)/start", method: "POST", requiresAuth: true)
        return try await performRequest(request)
    }
    
    // MARK: - Progress Endpoints
    
    func fetchProgress() async throws -> [HuntProgress] {
        let request = try buildRequest(endpoint: "/api/progress", requiresAuth: true)
        return try await performRequest(request)
    }
    
    func fetchProgress(huntId: String) async throws -> HuntProgress {
        let request = try buildRequest(endpoint: "/api/progress/\(huntId)", requiresAuth: true)
        return try await performRequest(request)
    }
    
    func checkIn(huntId: String, latitude: Double, longitude: Double) async throws -> CheckInResponse {
        let body = try JSONSerialization.data(withJSONObject: [
            "latitude": latitude,
            "longitude": longitude
        ])
        
        let request = try buildRequest(endpoint: "/api/progress/\(huntId)/checkin", method: "POST", body: body, requiresAuth: true)
        return try await performRequest(request)
    }
    
    func abandonHunt(huntId: String) async throws {
        let request = try buildRequest(endpoint: "/api/progress/\(huntId)", method: "DELETE", requiresAuth: true)
        let _: EmptyResponse = try await performRequest(request)
    }
    
    // MARK: - Leaderboard Endpoints
    
    func fetchLeaderboard(huntId: String) async throws -> [LeaderboardEntry] {
        let request = try buildRequest(endpoint: "/api/leaderboards/\(huntId)", requiresAuth: true)
        return try await performRequest(request)
    }
    
    func fetchGlobalLeaderboard() async throws -> [LeaderboardEntry] {
        let request = try buildRequest(endpoint: "/api/leaderboards/global", requiresAuth: true)
        return try await performRequest(request)
    }
}

// MARK: - Response Models

struct LoginResponse: Decodable {
    let token: String
}

struct ErrorResponse: Decodable {
    let error: String?
    let message: String?
}

struct EmptyResponse: Decodable {}

struct CheckInResponse: Decodable {
    let success: Bool
    let pointsEarned: Int
    let bonusPoints: Int
    let clueCompleted: Bool
    let huntCompleted: Bool
    let progress: HuntProgress?
}
