import SwiftUI
import Combine

@MainActor
class HuntSelectionViewModel: ObservableObject {
    @Published var hunts: [Hunt] = []
    @Published var filteredHunts: [Hunt] = []
    @Published var searchText: String = ""
    @Published var selectedDifficulty: HuntDifficulty?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            hunts = try await apiService.fetchHunts()
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func applyFilters() {
        var result = hunts
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let difficulty = selectedDifficulty {
            result = result.filter { $0.difficulty == difficulty }
        }
        
        filteredHunts = result
    }
    
    func clearFilters() {
        searchText = ""
        selectedDifficulty = nil
        applyFilters()
    }
}
