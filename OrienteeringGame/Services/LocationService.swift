import Foundation
import CoreLocation
import Combine

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var distanceToTarget: Double?
    @Published var isAtTarget: Bool = false
    @Published var heading: Double = 0
    
    private var targetLocation: CLLocation?
    private var checkInRadius: Double = 30
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.headingFilter = 5
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        isLocationEnabled = true
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        isLocationEnabled = false
    }
    
    func setTarget(location: HuntLocation, checkInRadius: Double = 30) {
        targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.checkInRadius = checkInRadius
        updateDistanceToTarget()
    }
    
    func clearTarget() {
        targetLocation = nil
        distanceToTarget = nil
        isAtTarget = false
    }
    
    private func updateDistanceToTarget() {
        guard let current = currentLocation, let target = targetLocation else {
            distanceToTarget = nil
            isAtTarget = false
            return
        }
        
        let distance = current.distance(from: target)
        distanceToTarget = distance
        isAtTarget = distance <= checkInRadius
    }
    
    func distanceTo(location: HuntLocation) -> Double? {
        guard let current = currentLocation else { return nil }
        let target = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return current.distance(from: target)
    }
    
    var formattedDistance: String? {
        guard let distance = distanceToTarget else { return nil }
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    var formattedAccuracy: String {
        guard let accuracy = currentLocation?.horizontalAccuracy else { return "--" }
        if accuracy < 0 {
            return "--"
        } else if accuracy < 10 {
            return String(format: "±%.0f m", accuracy)
        } else {
            return String(format: "±%.0f m", accuracy)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            isLocationEnabled = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            currentLocation = location
            updateDistanceToTarget()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error.localizedDescription)")
        }
    }
}
