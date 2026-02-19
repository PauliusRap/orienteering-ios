import Foundation

struct HuntProgress: Identifiable, Codable {
    let id: String
    let playerId: String
    let huntId: String
    let totalClues: Int
    var currentClueIndex: Int
    var completedClueIds: [String]
    var earnedPoints: Int
    let startedAt: Date
    var completedAt: Date?
    var isActive: Bool
    
    var progressPercentage: Double {
        guard totalClues > 0 else { return 0 }
        return Double(completedClueIds.count) / Double(totalClues) * 100
    }
    
    var isCompleted: Bool {
        completedAt != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, totalClues, earnedPoints, isActive
        case playerId = "player_id"
        case huntId = "hunt_id"
        case currentClueIndex = "current_clue_index"
        case completedClueIds = "completed_clue_ids"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: String
    let rank: Int
    let playerId: String
    let playerName: String
    let avatarUrl: String?
    let totalPoints: Int
    let completedHunts: Int
    
    var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalPoints)) ?? "\(totalPoints)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, rank, totalPoints, completedHunts
        case playerId = "player_id"
        case playerName = "player_name"
        case avatarUrl = "avatar_url"
    }
}

typealias PlayerProgress = HuntProgress
