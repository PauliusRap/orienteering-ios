import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var isChangingPassword: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    @Published var editUsername: String = ""
    @Published var editEmail: String = ""
    
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        user = apiService.currentUser
        editUsername = user?.username ?? ""
        editEmail = user?.email ?? ""
        
        apiService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$user)
    }
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.fetchProfile()
            editUsername = user?.username ?? ""
            editEmail = user?.email ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile() async -> Bool {
        guard !editUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            return false
        }
        
        isUpdating = true
        errorMessage = nil
        successMessage = nil
        
        do {
            _ = try await apiService.updateProfile(
                username: editUsername,
                email: editEmail.isEmpty ? nil : editEmail
            )
            successMessage = "Profile updated successfully"
            isUpdating = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func changePassword() async -> Bool {
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = "Please fill in all password fields"
            return false
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match"
            return false
        }
        
        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        isChangingPassword = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await apiService.changePassword(oldPassword: currentPassword, newPassword: newPassword)
            successMessage = "Password changed successfully"
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            isChangingPassword = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isChangingPassword = false
            return false
        }
    }
    
    func logout() async {
        await apiService.logout()
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
