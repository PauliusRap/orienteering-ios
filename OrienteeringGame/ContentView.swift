import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            HomeView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .huntSelection:
                        HuntSelectionView()
                    case .activeHunt(let huntId):
                        ActiveHuntView(huntId: huntId)
                    case .mapView(let huntId):
                        HuntMapView(huntId: huntId)
                    case .checkIn(let clueId):
                        CheckInView(clueId: clueId)
                    case .progress:
                        ProgressView()
                    }
                }
        }
        .tint(.orange)
    }
}

enum NavigationDestination: Hashable {
    case huntSelection
    case activeHunt(huntId: String)
    case mapView(huntId: String)
    case checkIn(clueId: String)
    case progress
}
