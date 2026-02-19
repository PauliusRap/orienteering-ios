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
    let clueIds: [String]
    let locationIds: [String]
    let isActive: Bool
    let createdAt: Date
    
    var difficultyStars: Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        case .expert: return 4
        }
    }
}

enum HuntDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "4CAF50"
        case .medium: return "FF9800"
        case .hard: return "F44336"
        case .expert: return "9C27B0"
        }
    }
}
