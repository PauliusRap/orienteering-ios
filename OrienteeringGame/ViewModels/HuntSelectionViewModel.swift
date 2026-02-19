import SwiftUI
import Combine

@MainActor
class HuntSelectionViewModel: ObservableObject {
    @Published var hunts: [Hunt] = []
    @Published var filteredHunts: [Hunt] = []
    @Published var searchText: String = ""
    @Published var selectedDifficulty: HuntDifficulty?
    @Published var isLoading: Bool = true
    
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func load() {
        isLoading = true
        hunts = dataService.hunts.filter { $0.isActive }
        applyFilters()
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
