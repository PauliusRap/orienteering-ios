import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var currentPlayer: Player?
    @Published var isOnHunt: Bool = false
    @Published var activeHuntId: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCurrentPlayer()
    }
    
    func loadCurrentPlayer() {
        currentPlayer = MockDataService.shared.currentPlayer
    }
    
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func startHunt(huntId: String) {
        activeHuntId = huntId
        isOnHunt = true
        navigate(to: .activeHunt(huntId: huntId))
    }
    
    func endHunt() {
        activeHuntId = nil
        isOnHunt = false
        navigationPath = NavigationPath()
    }
}
