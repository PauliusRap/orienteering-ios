import SwiftUI
import Combine
import MapKit

@MainActor
class HuntMapViewModel: ObservableObject {
    @Published var hunt: Hunt?
    @Published var locations: [HuntLocation] = []
    @Published var annotations: [HuntAnnotation] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var selectedLocation: HuntLocation?
    @Published var isLoading: Bool = true
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    
    private let huntId: String
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(huntId: String) {
        self.huntId = huntId
    }
    
    func load() {
        isLoading = true
        hunt = dataService.getHunt(by: huntId)
        locations = dataService.getLocations(for: huntId)
        
        annotations = locations.enumerated().map { index, location in
            HuntAnnotation(
                id: location.id,
                coordinate: location.coordinate,
                title: "Stop \(index + 1)",
                subtitle: location.name
            )
        }
        
        if let firstLocation = locations.first {
            region = MKCoordinateRegion(
                center: firstLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
        
        isLoading = false
    }
    
    func centerOnUserLocation(locationService: LocationService) {
        guard let userLocation = locationService.currentLocation else { return }
        withAnimation {
            region.center = userLocation.coordinate
        }
    }
    
    func centerOnLocation(_ location: HuntLocation) {
        withAnimation {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        }
        selectedLocation = location
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
