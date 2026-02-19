import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let email: String?
    let isAdmin: Bool?
    let createdAt: Date?
    
    // Computed/display properties - not from API
    var displayName: String?
    var avatarUrl: String?
    var totalPoints: Int = 0
    var completedHunts: Int = 0
    var currentStreak: Int = 0
    
    var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalPoints)) ?? "\(totalPoints)"
    }
    
    var displayTitle: String {
        displayName ?? username
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case isAdmin = "is_admin"
        case createdAt = "created_at"
    }
    
    // Custom decoder to handle partial data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        
        // Initialize defaults for computed fields
        displayName = nil
        avatarUrl = nil
        totalPoints = 0
        completedHunts = 0
        currentStreak = 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}
