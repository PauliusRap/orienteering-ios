import Foundation

struct Hunt: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let difficulty: HuntDifficulty
    let estimatedDuration: Int
    let totalClues: Int
    let totalPoints: Int
    let imageUrl: String?
    let isActive: Bool
    let createdAt: Date
    
    var difficultyStars: Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, difficulty
        case estimatedDuration = "estimated_duration"
        case totalClues = "total_clues"
        case totalPoints = "total_points"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct HuntDetail: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let difficulty: HuntDifficulty
    let estimatedDuration: Int
    let totalClues: Int
    let totalPoints: Int
    let imageUrl: String?
    let clues: [Clue]
    let isActive: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, difficulty, clues
        case estimatedDuration = "estimated_duration"
        case totalClues = "total_clues"
        case totalPoints = "total_points"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

enum HuntDifficulty: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayValue: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "4CAF50"
        case .medium: return "FF9800"
        case .hard: return "F44336"
        }
    }
}
