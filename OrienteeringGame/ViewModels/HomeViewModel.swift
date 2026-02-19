import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var player: Player?
    @Published var nearbyHunts: [Hunt] = []
    @Published var recentProgress: [PlayerProgress] = []
    @Published var isLoading: Bool = true
    
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func load() {
        isLoading = true
        player = dataService.currentPlayer
        nearbyHunts = Array(dataService.hunts.prefix(3))
        recentProgress = dataService.playerProgress.filter { $0.isActive || $0.isCompleted }.prefix(3).map { $0 }
        isLoading = false
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
}
