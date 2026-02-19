import SwiftUI

@main
struct OrienteeringGameApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(LocationService.shared)
        }
    }
}
