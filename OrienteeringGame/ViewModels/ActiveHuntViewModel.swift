import SwiftUI
import Combine

@MainActor
class ActiveHuntViewModel: ObservableObject {
    @Published var hunt: Hunt?
    @Published var clues: [Clue] = []
    @Published var currentClue: Clue?
    @Published var progress: PlayerProgress?
    @Published var currentClueIndex: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isLoading: Bool = true
    @Published var showingCompletion: Bool = false
    
    private let huntId: String
    private let dataService = MockDataService.shared
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(huntId: String) {
        self.huntId = huntId
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func load() {
        isLoading = true
        hunt = dataService.getHunt(by: huntId)
        clues = dataService.getClues(for: huntId)
        
        if let existingProgress = dataService.getProgress(for: huntId) {
            progress = existingProgress
            currentClueIndex = existingProgress.currentClueIndex
        } else {
            progress = dataService.startHunt(huntId: huntId)
            currentClueIndex = 0
        }
        
        updateCurrentClue()
        startTimer()
        isLoading = false
    }
    
    private func updateCurrentClue() {
        guard currentClueIndex < clues.count else {
            currentClue = nil
            return
        }
        currentClue = clues[currentClueIndex]
    }
    
    private func startTimer() {
        guard let progress = progress else { return }
        let startTime = progress.startedAt
        elapsedTime = Date().timeIntervalSince(startTime)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func completeCurrentClue() {
        guard let clue = currentClue else { return }
        dataService.completeClue(clue.id, in: huntId)
        progress = dataService.getProgress(for: huntId)
        
        currentClueIndex += 1
        updateCurrentClue()
        
        if currentClue == nil {
            timer?.invalidate()
            showingCompletion = true
        }
    }
    
    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progressPercentage: Double {
        guard let hunt = hunt else { return 0 }
        return Double(currentClueIndex) / Double(hunt.totalClues) * 100
    }
    
    var currentTargetLocation: HuntLocation? {
        guard let clue = currentClue else { return nil }
        return dataService.getLocation(by: clue.locationId)
    }
}
