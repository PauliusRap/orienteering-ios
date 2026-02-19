import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditProfile: Bool = false
    @State private var showingChangePassword: Bool = false
    @State private var showingLogoutConfirmation: Bool = false
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    profileCard
                    menuSection
                    logoutSection
                }
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadProfile()
            }
        }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordSheet(viewModel: viewModel)
        }
        .alert("Log Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "F59E0B"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "1F1F2E"))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Profile")
                .font(.custom("Avenir-Black", size: 22))
                .foregroundColor(.white)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
    
    private var profileCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(viewModel.user?.username.prefix(2).uppercased() ?? "??")
                    .font(.custom("Avenir-Black", size: 36))
                    .foregroundColor(Color(hex: "0A0A0F"))
            }
            
            VStack(spacing: 8) {
                Text(viewModel.user?.username ?? "User")
                    .font(.custom("Avenir-Black", size: 24))
                    .foregroundColor(.white)
                
                Text(viewModel.user?.email ?? "No email")
                    .font(.custom("Avenir-Book", size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                
                if let isAdmin = viewModel.user?.isAdmin, isAdmin {
                    Text("ADMIN")
                        .font(.custom("Avenir-Black", size: 10))
                        .foregroundColor(Color(hex: "F59E0B"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: "F59E0B").opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(hex: "151520"))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
    
    private var menuSection: some View {
        VStack(spacing: 12) {
            MenuItem(
                icon: "person.fill",
                title: "Edit Profile",
                subtitle: "Change username or email",
                color: Color(hex: "3B82F6")
            ) {
                showingEditProfile = true
            }
            
            MenuItem(
                icon: "lock.fill",
                title: "Change Password",
                subtitle: "Update your password",
                color: Color(hex: "8B5CF6")
            ) {
                showingChangePassword = true
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private var logoutSection: some View {
        VStack(spacing: 12) {
            Button {
                showingLogoutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    Text("Log Out")
                        .font(.custom("Avenir-Heavy", size: 16))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "EF4444").opacity(0.1))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Avenir-Heavy", size: 16))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.custom("Avenir-Book", size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "4B5563"))
            }
            .padding(16)
            .background(Color(hex: "151520"))
            .cornerRadius(16)
        }
    }
}

struct EditProfileSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case username, email
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        InputField(
                            title: "Username",
                            placeholder: "Enter username",
                            text: $viewModel.editUsername,
                            icon: "person.fill"
                        )
                        .focused($focusedField, equals: .username)
                        
                        InputField(
                            title: "Email",
                            placeholder: "Enter email",
                            text: $viewModel.editEmail,
                            icon: "envelope.fill"
                        )
                        .focused($focusedField, equals: .email)
                        .keyboardType(.emailAddress)
                    }
                    
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(hex: "EF4444"))
                            
                            Text(error)
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(Color(hex: "EF4444"))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "EF4444").opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            if await viewModel.updateProfile() {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isUpdating {
                            ProgressView()
                                .tint(Color(hex: "0A0A0F"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Save Changes")
                                .font(.custom("Avenir-Black", size: 18))
                                .foregroundColor(Color(hex: "0A0A0F"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(viewModel.isUpdating)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.clearMessages()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6B7280"))
                }
            }
            .toolbarBackground(Color(hex: "0A0A0F"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct ChangePasswordSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case current, new, confirm
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        InputField(
                            title: "Current Password",
                            placeholder: "Enter current password",
                            text: $viewModel.currentPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .current)
                        
                        InputField(
                            title: "New Password",
                            placeholder: "Enter new password",
                            text: $viewModel.newPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .new)
                        
                        InputField(
                            title: "Confirm Password",
                            placeholder: "Confirm new password",
                            text: $viewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .confirm)
                    }
                    
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(hex: "EF4444"))
                            
                            Text(error)
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(Color(hex: "EF4444"))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "EF4444").opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            if await viewModel.changePassword() {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isChangingPassword {
                            ProgressView()
                                .tint(Color(hex: "0A0A0F"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Change Password")
                                .font(.custom("Avenir-Black", size: 18))
                                .foregroundColor(Color(hex: "0A0A0F"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(viewModel.isChangingPassword)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.clearMessages()
                        viewModel.currentPassword = ""
                        viewModel.newPassword = ""
                        viewModel.confirmPassword = ""
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6B7280"))
                }
            }
            .toolbarBackground(Color(hex: "0A0A0F"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
