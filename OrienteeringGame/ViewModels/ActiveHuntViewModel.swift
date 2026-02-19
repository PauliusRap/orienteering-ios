import SwiftUI
import Combine

@MainActor
class ActiveHuntViewModel: ObservableObject {
    @Published var hunt: Hunt?
    @Published var huntDetail: HuntDetail?
    @Published var clues: [Clue] = []
    @Published var currentClue: Clue?
    @Published var progress: HuntProgress?
    @Published var currentClueIndex: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isLoading: Bool = true
    @Published var showingCompletion: Bool = false
    @Published var errorMessage: String?
    
    private let huntId: String
    private let apiService = APIService.shared
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(huntId: String) {
        self.huntId = huntId
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await apiService.fetchHunt(id: huntId)
            huntDetail = detail
            hunt = Hunt(
                id: detail.id,
                name: detail.name,
                description: detail.description,
                difficulty: detail.difficulty,
                estimatedDuration: detail.estimatedDuration,
                totalClues: detail.totalClues,
                totalPoints: detail.totalPoints,
                imageUrl: detail.imageUrl,
                isActive: detail.isActive,
                createdAt: detail.createdAt
            )
            clues = detail.clues.sorted { $0.order < $1.order }
            
            if let existingProgress = try? await apiService.fetchProgress(huntId: huntId) {
                progress = existingProgress
                currentClueIndex = existingProgress.currentClueIndex
            } else {
                progress = try await apiService.startHunt(id: huntId)
                currentClueIndex = 0
            }
            
            updateCurrentClue()
            startTimer()
        } catch {
            errorMessage = error.localizedDescription
        }
        
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
        guard currentClue != nil else { return }
        
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
}
