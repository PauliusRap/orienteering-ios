import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case username, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    
                    formSection
                    
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                    
                    actionSection
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
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
            }
            
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.custom("Avenir-Black", size: 32))
                    .foregroundColor(.white)
                
                Text("Join the adventure today")
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Username",
                placeholder: "Choose a username",
                text: $username,
                icon: "person.fill"
            )
            .focused($focusedField, equals: .username)
            
            InputField(
                title: "Email",
                placeholder: "Enter your email",
                text: $email,
                icon: "envelope.fill"
            )
            .focused($focusedField, equals: .email)
            .keyboardType(.emailAddress)
            
            InputField(
                title: "Password",
                placeholder: "Create a password",
                text: $password,
                icon: "lock.fill",
                isSecure: true
            )
            .focused($focusedField, equals: .password)
            
            InputField(
                title: "Confirm Password",
                placeholder: "Confirm your password",
                text: $confirmPassword,
                icon: "lock.fill",
                isSecure: true
            )
            .focused($focusedField, equals: .confirmPassword)
            
            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    Text("Passwords do not match")
                        .font(.custom("Avenir-Medium", size: 13))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                    await viewModel.register(username: username, email: email, password: password)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color(hex: "0A0A0F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                } else {
                    Text("Create Account")
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
            .disabled(viewModel.isLoading || !isFormValid)
            .opacity((viewModel.isLoading || !isFormValid) ? 0.6 : 1)
            
            HStack(spacing: 8) {
                Text("Already have an account?")
                    .font(.custom("Avenir-Book", size: 15))
                    .foregroundColor(Color(hex: "6B7280"))
                
                Button {
                    dismiss()
                } label: {
                    Text("Sign In")
                        .font(.custom("Avenir-Heavy", size: 15))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
}
