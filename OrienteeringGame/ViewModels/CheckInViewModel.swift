import SwiftUI
import Combine

@MainActor
class CheckInViewModel: ObservableObject {
    @Published var clue: Clue?
    @Published var location: HuntLocation?
    @Published var isVerifying: Bool = false
    @Published var isCheckInSuccessful: Bool = false
    @Published var checkInFailed: Bool = false
    @Published var distance: Double?
    @Published var isWithinRange: Bool = false
    
    private let clueId: String
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(clueId: String) {
        self.clueId = clueId
    }
    
    func load() {
        clue = dataService.clues.first { $0.id == clueId }
        if let locationId = clue?.locationId {
            location = dataService.getLocation(by: locationId)
        }
    }
    
    func updateDistance(locationService: LocationService) {
        guard let location = location else {
            distance = nil
            isWithinRange = false
            return
        }
        
        distance = locationService.distanceTo(location: location)
        isWithinRange = (distance ?? Double.infinity) <= 30
    }
    
    func attemptCheckIn(locationService: LocationService) {
        guard isWithinRange else {
            checkInFailed = true
            return
        }
        
        isVerifying = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                isVerifying = false
                isCheckInSuccessful = true
                
                if let clueId = clue?.id, let huntId = clue?.huntId {
                    dataService.completeClue(clueId, in: huntId)
                }
            }
        }
    }
    
    var formattedDistance: String {
        guard let distance = distance else { return "--" }
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
