import SwiftUI
import Combine

@MainActor
class CheckInViewModel: ObservableObject {
    @Published var clue: Clue?
    @Published var isVerifying: Bool = false
    @Published var isCheckInSuccessful: Bool = false
    @Published var checkInFailed: Bool = false
    @Published var distance: Double?
    @Published var isWithinRange: Bool = false
    @Published var pointsEarned: Int = 0
    @Published var bonusPoints: Int = 0
    @Published var errorMessage: String?
    
    private let clueId: String
    private let huntId: String
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(clueId: String, huntId: String) {
        self.clueId = clueId
        self.huntId = huntId
    }
    
    func setClue(_ clue: Clue) {
        self.clue = clue
    }
    
    func updateDistance(locationService: LocationService) {
        guard let clue = clue else {
            distance = nil
            isWithinRange = false
            return
        }
        
        distance = locationService.distanceTo(latitude: clue.latitude, longitude: clue.longitude)
        isWithinRange = (distance ?? Double.infinity) <= clue.radius
    }
    
    func attemptCheckIn(locationService: LocationService) async {
        guard isWithinRange else {
            checkInFailed = true
            return
        }
        
        guard let currentLocation = locationService.currentLocation else {
            checkInFailed = true
            return
        }
        
        isVerifying = true
        errorMessage = nil
        
        do {
            let response = try await apiService.checkIn(
                huntId: huntId,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
            
            if response.success {
                isCheckInSuccessful = true
                pointsEarned = response.pointsEarned
                bonusPoints = response.bonusPoints
            } else {
                checkInFailed = true
                errorMessage = "Check-in failed. Please try again."
            }
        } catch {
            checkInFailed = true
            errorMessage = error.localizedDescription
        }
        
        isVerifying = false
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
