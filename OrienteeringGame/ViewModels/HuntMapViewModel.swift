import SwiftUI
import Combine
import MapKit

@MainActor
class HuntMapViewModel: ObservableObject {
    @Published var hunt: Hunt?
    @Published var clues: [Clue] = []
    @Published var annotations: [HuntAnnotation] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var selectedClue: Clue?
    @Published var isLoading: Bool = true
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    @Published var errorMessage: String?
    
    private let huntId: String
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(huntId: String) {
        self.huntId = huntId
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await apiService.fetchHunt(id: huntId)
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
            
            annotations = clues.map { clue in
                HuntAnnotation(
                    id: clue.id,
                    coordinate: clue.coordinate,
                    title: "Clue #\(clue.order)",
                    subtitle: clue.hint
                )
            }
            
            if let firstClue = clues.first {
                region = MKCoordinateRegion(
                    center: firstClue.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func centerOnUserLocation(locationService: LocationService) {
        guard let userLocation = locationService.currentLocation else { return }
        withAnimation {
            region.center = userLocation.coordinate
        }
    }
    
    func centerOnClue(_ clue: Clue) {
        withAnimation {
            region.center = clue.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        }
        selectedClue = clue
    }
}

class HuntAnnotation: NSObject, Identifiable, MKAnnotation {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
