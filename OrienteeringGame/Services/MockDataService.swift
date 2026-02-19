import Foundation
import CoreLocation

@MainActor
class MockDataService: ObservableObject {
    static let shared = MockDataService()
    
    @Published var hunts: [Hunt] = []
    @Published var clues: [Clue] = []
    @Published var locations: [HuntLocation] = []
    @Published var currentPlayer: Player
    @Published var playerProgress: [PlayerProgress] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    
    private init() {
        currentPlayer = Player(
            id: "player-1",
            username: "explorer",
            displayName: "Trail Blazer",
            avatarUrl: nil,
            joinedAt: Date().addingTimeInterval(-86400 * 30),
            totalPoints: 2450,
            completedHunts: 5,
            currentStreak: 3
        )
        
        generateMockData()
    }
    
    private func generateMockData() {
        locations = [
            HuntLocation(id: "loc-1", name: "Central Park Fountain", latitude: 40.7829, longitude: -73.9654, hint: "Where water dances toward the sky"),
            HuntLocation(id: "loc-2", name: "Historic Clock Tower", latitude: 40.7835, longitude: -73.9660, hint: "Time stands still yet never stops moving"),
            HuntLocation(id: "loc-3", name: "Secret Garden Gate", latitude: 40.7840, longitude: -73.9670, hint: "Nature's entrance hidden in plain sight"),
            HuntLocation(id: "loc-4", name: "Bronze Statue Plaza", latitude: 40.7845, longitude: -73.9680, hint: "Metal figures frozen in eternal pose"),
            HuntLocation(id: "loc-5", name: "Riverside Bridge", latitude: 40.7850, longitude: -73.9690, hint: "Cross over where water flows below"),
            HuntLocation(id: "loc-6", name: "Library Steps", latitude: 40.7532, longitude: -73.9822, hint: "Where knowledge awaits behind stone lions"),
            HuntLocation(id: "loc-7", name: "Market Square", latitude: 40.7484, longitude: -73.9857, hint: "Sounds of commerce fill the air"),
            HuntLocation(id: "loc-8", name: "Old Town Hall", latitude: 40.7127, longitude: -74.0059, hint: "Where history meets the present")
        ]
        
        clues = [
            Clue(id: "clue-1", huntId: "hunt-1", order: 1, title: "The Water's Edge", riddle: "Find the place where water leaps toward the heavens, a stone guardian watches nearby.", locationId: "loc-1", points: 100, timeBonus: 30),
            Clue(id: "clue-2", huntId: "hunt-1", order: 2, title: "Time's Witness", riddle: "Where hands move but never touch, twelve numbers mark the passing hours.", locationId: "loc-2", points: 150, timeBonus: 25),
            Clue(id: "clue-3", huntId: "hunt-1", order: 3, title: "Hidden Green", riddle: "A gate of iron leads to a world of green, seek the entrance few have seen.", locationId: "loc-3", points: 200, timeBonus: 20),
            Clue(id: "clue-4", huntId: "hunt-1", order: 4, title: "Metal Men", riddle: "Frozen in bronze they stand eternal, telling stories without words.", locationId: "loc-4", points: 250, timeBonus: 15),
            Clue(id: "clue-5", huntId: "hunt-1", order: 5, title: "Final Crossing", riddle: "Where land meets water, an arc of stone helps travelers pass.", locationId: "loc-5", points: 300, timeBonus: 10),
            Clue(id: "clue-6", huntId: "hunt-2", order: 1, title: "Lions Guard", riddle: "Stone kings of the jungle guard vast halls of paper and ink.", locationId: "loc-6", points: 120, timeBonus: 30),
            Clue(id: "clue-7", huntId: "hunt-2", order: 2, title: "Market Maze", riddle: "A labyrinth of stalls and sounds, treasures await those who search.", locationId: "loc-7", points: 180, timeBonus: 25),
            Clue(id: "clue-8", huntId: "hunt-2", order: 3, title: "Council's Home", riddle: "Where leaders once gathered to shape the city's fate.", locationId: "loc-8", points: 250, timeBonus: 20)
        ]
        
        hunts = [
            Hunt(
                id: "hunt-1",
                name: "Park Explorer",
                description: "Discover hidden gems in the heart of the city's greenest space. Perfect for beginners!",
                difficulty: .easy,
                estimatedDuration: 45,
                totalClues: 5,
                totalPoints: 1000,
                imageUrl: nil,
                clueIds: ["clue-1", "clue-2", "clue-3", "clue-4", "clue-5"],
                locationIds: ["loc-1", "loc-2", "loc-3", "loc-4", "loc-5"],
                isActive: true,
                createdAt: Date().addingTimeInterval(-86400 * 14)
            ),
            Hunt(
                id: "hunt-2",
                name: "Downtown Discovery",
                description: "Uncover the secrets of the bustling downtown district. Navigate through history!",
                difficulty: .medium,
                estimatedDuration: 60,
                totalClues: 3,
                totalPoints: 550,
                imageUrl: nil,
                clueIds: ["clue-6", "clue-7", "clue-8"],
                locationIds: ["loc-6", "loc-7", "loc-8"],
                isActive: true,
                createdAt: Date().addingTimeInterval(-86400 * 7)
            ),
            Hunt(
                id: "hunt-3",
                name: "Ghost Trail",
                description: "Follow the footsteps of the past through haunted historic locations. Not for the faint-hearted!",
                difficulty: .hard,
                estimatedDuration: 90,
                totalClues: 7,
                totalPoints: 2000,
                imageUrl: nil,
                clueIds: ["clue-1", "clue-2", "clue-3", "clue-4", "clue-5", "clue-6", "clue-7"],
                locationIds: ["loc-1", "loc-2", "loc-3", "loc-4", "loc-5", "loc-6", "loc-7"],
                isActive: true,
                createdAt: Date().addingTimeInterval(-86400 * 3)
            ),
            Hunt(
                id: "hunt-4",
                name: "Urban Legend",
                description: "The ultimate challenge for expert explorers. Every corner holds a mystery.",
                difficulty: .expert,
                estimatedDuration: 120,
                totalClues: 8,
                totalPoints: 3500,
                imageUrl: nil,
                clueIds: ["clue-1", "clue-2", "clue-3", "clue-4", "clue-5", "clue-6", "clue-7", "clue-8"],
                locationIds: ["loc-1", "loc-2", "loc-3", "loc-4", "loc-5", "loc-6", "loc-7", "loc-8"],
                isActive: true,
                createdAt: Date()
            )
        ]
        
        leaderboard = [
            LeaderboardEntry(id: "lb-1", rank: 1, playerId: "player-2", playerName: "Shadow Walker", avatarUrl: nil, totalPoints: 15200, completedHunts: 12),
            LeaderboardEntry(id: "lb-2", rank: 2, playerId: "player-3", playerName: "Urban Scout", avatarUrl: nil, totalPoints: 12450, completedHunts: 10),
            LeaderboardEntry(id: "lb-3", rank: 3, playerId: "player-4", playerName: "Path Finder", avatarUrl: nil, totalPoints: 9800, completedHunts: 8),
            LeaderboardEntry(id: "lb-4", rank: 4, playerId: "player-5", playerName: "City Rover", avatarUrl: nil, totalPoints: 7650, completedHunts: 7),
            LeaderboardEntry(id: "lb-5", rank: 5, playerId: "player-1", playerName: "Trail Blazer", avatarUrl: nil, totalPoints: 2450, completedHunts: 5),
            LeaderboardEntry(id: "lb-6", rank: 6, playerId: "player-6", playerName: "Quest Master", avatarUrl: nil, totalPoints: 2100, completedHunts: 4),
            LeaderboardEntry(id: "lb-7", rank: 7, playerId: "player-7", playerName: "Map Reader", avatarUrl: nil, totalPoints: 1800, completedHunts: 3),
            LeaderboardEntry(id: "lb-8", rank: 8, playerId: "player-8", playerName: "Trail Runner", avatarUrl: nil, totalPoints: 1450, completedHunts: 3),
            LeaderboardEntry(id: "lb-9", rank: 9, playerId: "player-9", playerName: "Nature Seeker", avatarUrl: nil, totalPoints: 900, completedHunts: 2),
            LeaderboardEntry(id: "lb-10", rank: 10, playerId: "player-10", playerName: "Newcomer", avatarUrl: nil, totalPoints: 350, completedHunts: 1)
        ]
    }
    
    func getHunt(by id: String) -> Hunt? {
        hunts.first { $0.id == id }
    }
    
    func getClues(for huntId: String) -> [Clue] {
        clues.filter { $0.huntId == huntId }.sorted { $0.order < $1.order }
    }
    
    func getLocation(by id: String) -> HuntLocation? {
        locations.first { $0.id == id }
    }
    
    func getLocations(for huntId: String) -> [HuntLocation] {
        guard let hunt = getHunt(by: huntId) else { return [] }
        return hunt.locationIds.compactMap { getLocation(by: $0) }
    }
    
    func getProgress(for huntId: String) -> PlayerProgress? {
        playerProgress.first { $0.huntId == huntId }
    }
    
    func startHunt(huntId: String) -> PlayerProgress? {
        guard let hunt = getHunt(by: huntId) else { return nil }
        let progress = PlayerProgress(
            id: "progress-\(huntId)-\(UUID().uuidString.prefix(8))",
            playerId: currentPlayer.id,
            huntId: huntId,
            totalClues: hunt.totalClues,
            currentClueIndex: 0,
            completedClueIds: [],
            earnedPoints: 0,
            startedAt: Date(),
            completedAt: nil,
            isActive: true
        )
        playerProgress.append(progress)
        return progress
    }
    
    func completeClue(_ clueId: String, in huntId: String) {
        guard let clue = clues.first(where: { $0.id == clueId }) else { return }
        guard let progressIndex = playerProgress.firstIndex(where: { $0.huntId == huntId && $0.isActive }) else { return }
        
        var progress = playerProgress[progressIndex]
        
        if !progress.completedClueIds.contains(clueId) {
            progress.completedClueIds.append(clueId)
            progress.earnedPoints += clue.points
            progress.currentClueIndex += 1
            
            if let hunt = getHunt(by: huntId), progress.completedClueIds.count >= hunt.totalClues {
                progress.completedAt = Date()
                progress.isActive = false
                currentPlayer.totalPoints += progress.earnedPoints
                currentPlayer.completedHunts += 1
            }
            
            playerProgress[progressIndex] = progress
        }
    }
    
    func getPlayerRank() -> Int {
        leaderboard.first { $0.playerId == currentPlayer.id }?.rank ?? 0
    }
}
