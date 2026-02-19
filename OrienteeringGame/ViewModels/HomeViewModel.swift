import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var nearbyHunts: [Hunt] = []
    @Published var recentProgress: [HuntProgress] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = apiService.currentUser
            
            async let huntsTask = apiService.fetchHunts()
            async let progressTask = apiService.fetchProgress()
            
            let hunts = try await huntsTask
            let progress = try await progressTask
            
            nearbyHunts = Array(hunts.prefix(3))
            recentProgress = progress.filter { $0.isActive || $0.isCompleted }.prefix(3).map { $0 }
        } catch {
            errorMessage = error.localizedDescription
        }
        
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
