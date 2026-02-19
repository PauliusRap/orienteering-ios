import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainAppView()
                    .environmentObject(appState)
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
        .tint(.orange)
    }
}

struct MainAppView: View {
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
                    case .checkIn(let clueId, let huntId):
                        CheckInView(clueId: clueId, huntId: huntId)
                    case .progress:
                        ProgressView()
                    case .profile:
                        ProfileView()
                    }
                }
        }
    }
}

enum NavigationDestination: Hashable {
    case huntSelection
    case activeHunt(huntId: String)
    case mapView(huntId: String)
    case checkIn(clueId: String, huntId: String)
    case progress
    case profile
}
