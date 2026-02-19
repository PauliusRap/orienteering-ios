import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingRegister: Bool = false
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                headerSection
                
                Spacer()
                
                formSection
                
                if let error = viewModel.errorMessage {
                    errorView(error)
                }
                
                Spacer()
                
                actionSection
            }
            .padding(.horizontal, 32)
        }
        .fullScreenCover(isPresented: $showingRegister) {
            RegisterView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 24) {
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
                
                Image(systemName: "compass.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(Color(hex: "0A0A0F"))
            }
            
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.custom("Avenir-Black", size: 32))
                    .foregroundColor(.white)
                
                Text("Sign in to continue your adventure")
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Username",
                placeholder: "Enter your username",
                text: $username,
                icon: "person.fill"
            )
            
            InputField(
                title: "Password",
                placeholder: "Enter your password",
                text: $password,
                icon: "lock.fill",
                isSecure: true
            )
        }
    }
    
    private func errorView(_ error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color(hex: "EF4444"))
            
            Text(error)
                .font(.custom("Avenir-Medium", size: 14))
                .foregroundColor(Color(hex: "EF4444"))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "EF4444").opacity(0.1))
        .cornerRadius(12)
        .padding(.top, 20)
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.login(username: username, password: password)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color(hex: "0A0A0F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                } else {
                    Text("Sign In")
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
            .disabled(viewModel.isLoading || username.isEmpty || password.isEmpty)
            .opacity((viewModel.isLoading || username.isEmpty || password.isEmpty) ? 0.6 : 1)
            
            HStack(spacing: 8) {
                Text("Don't have an account?")
                    .font(.custom("Avenir-Book", size: 15))
                    .foregroundColor(Color(hex: "6B7280"))
                
                Button {
                    showingRegister = true
                } label: {
                    Text("Sign Up")
                        .font(.custom("Avenir-Heavy", size: 15))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
        }
        .padding(.bottom, 40)
    }
}

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Avenir-Heavy", size: 14))
                .foregroundColor(Color(hex: "9CA3AF"))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 24)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.custom("Avenir-Book", size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    TextField(placeholder, text: $text)
                        .font(.custom("Avenir-Book", size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .padding(16)
            .background(Color(hex: "151520"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "2D2D3D"), lineWidth: 1)
            )
        }
    }
}
