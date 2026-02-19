import Foundation

struct PlayerProgress: Identifiable, Codable {
    let id: String
    let playerId: String
    let huntId: String
    let totalClues: Int
    var currentClueIndex: Int
    var completedClueIds: [String]
    var earnedPoints: Int
    var startedAt: Date
    var completedAt: Date?
    var isActive: Bool
    
    var progressPercentage: Double {
        guard totalClues > 0 else { return 0 }
        return Double(completedClueIds.count) / Double(totalClues) * 100
    }
    
    var isCompleted: Bool {
        completedAt != nil
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
}
