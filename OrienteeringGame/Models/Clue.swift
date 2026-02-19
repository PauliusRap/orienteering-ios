import Foundation
import CoreLocation

struct Clue: Identifiable, Codable, Hashable {
    let id: String
    let huntId: String
    let order: Int
    let hint: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func == (lhs: Clue, rhs: Clue) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, order, hint, latitude, longitude, radius
        case huntId = "hunt_id"
    }
}
