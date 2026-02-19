import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        isAuthenticated = apiService.isAuthenticated
        currentUser = apiService.currentUser
        
        apiService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        apiService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.login(username: username, password: password)
            isAuthenticated = true
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
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        await apiService.logout()
        isAuthenticated = false
        currentUser = nil
    }
    
    func refreshProfile() async {
        do {
            _ = try await apiService.fetchProfile()
        } catch {
            print("Failed to refresh profile: \(error)")
        }
    }
}
