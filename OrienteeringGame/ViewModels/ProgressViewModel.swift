import SwiftUI
import Combine

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var player: Player?
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var playerRank: Int = 0
    @Published var completedHunts: [PlayerProgress] = []
    @Published var activeHunts: [PlayerProgress] = []
    @Published var isLoading: Bool = true
    @Published var selectedTab: ProgressTab = .overview
    
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum ProgressTab: String, CaseIterable {
        case overview = "Overview"
        case leaderboard = "Leaderboard"
        case history = "History"
    }
    
    func load() {
        isLoading = true
        player = dataService.currentPlayer
        leaderboard = dataService.leaderboard
        playerRank = dataService.getPlayerRank()
        
        let allProgress = dataService.playerProgress
        completedHunts = allProgress.filter { $0.isCompleted }.sorted { $0.completedAt ?? .distantPast > $1.completedAt ?? .distantPast }
        activeHunts = allProgress.filter { $0.isActive }
        
        isLoading = false
    }
    
    func getHuntName(for huntId: String) -> String {
        dataService.getHunt(by: huntId)?.name ?? "Unknown Hunt"
    }
    
    func formatDuration(from start: Date, to end: Date?) -> String {
        let endDate = end ?? Date()
        let interval = endDate.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}
