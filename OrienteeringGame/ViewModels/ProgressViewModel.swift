import SwiftUI
import Combine

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var user: User?
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var playerRank: Int = 0
    @Published var completedHunts: [HuntProgress] = []
    @Published var activeHunts: [HuntProgress] = []
    @Published var isLoading: Bool = true
    @Published var selectedTab: ProgressTab = .overview
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum ProgressTab: String, CaseIterable {
        case overview = "Overview"
        case leaderboard = "Leaderboard"
        case history = "History"
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = apiService.currentUser
            
            async let progressTask = apiService.fetchProgress()
            async let leaderboardTask = apiService.fetchGlobalLeaderboard()
            
            let progress = try await progressTask
            let leaderboardData = try await leaderboardTask
            
            leaderboard = leaderboardData
            playerRank = leaderboard.first { $0.playerId == user?.id }?.rank ?? 0
            
            completedHunts = progress.filter { $0.isCompleted }.sorted { $0.completedAt ?? .distantPast > $1.completedAt ?? .distantPast }
            activeHunts = progress.filter { $0.isActive }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getHuntName(for huntId: String) -> String {
        "Hunt \(huntId.prefix(8))"
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
