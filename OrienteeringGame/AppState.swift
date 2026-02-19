import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var currentUser: User?
    @Published var isOnHunt: Bool = false
    @Published var activeHuntId: String?
    @Published var activeHuntDetail: HuntDetail?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCurrentUser()
    }
    
    func loadCurrentUser() {
        currentUser = APIService.shared.currentUser
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
        activeHuntDetail = nil
        navigationPath = NavigationPath()
    }
}
