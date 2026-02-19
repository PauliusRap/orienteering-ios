import Foundation

struct Clue: Identifiable, Codable, Hashable {
    let id: String
    let huntId: String
    let order: Int
    let title: String
    let riddle: String
    let locationId: String
    let points: Int
    let timeBonus: Int
    var isUnlocked: Bool = false
    var isCompleted: Bool = false
    var completedAt: Date?
    
    static func == (lhs: Clue, rhs: Clue) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
