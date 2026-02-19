import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let apiService = APIService.shared
    
    var isAuthenticated: Bool { apiService.isAuthenticated }
    var currentUser: User? { apiService.currentUser }
    
    init() {}
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.login(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.register(username: username, email: email, password: password)
            // After successful registration, automatically login
            _ = try await apiService.login(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        await apiService.logout()
    }
    
    func refreshProfile() async {
        do {
            _ = try await apiService.fetchProfile()
        } catch {
            print("Failed to refresh profile: \(error)")
        }
    }
}
