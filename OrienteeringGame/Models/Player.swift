import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let avatarUrl: String?
    let joinedAt: Date
    var totalPoints: Int
    var completedHunts: Int
    var currentStreak: Int
    
    var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalPoints)) ?? "\(totalPoints)"
    }
}
