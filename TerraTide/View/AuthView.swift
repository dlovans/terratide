//
//  AuthView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var locationService: LocationService
    
    @State private var authType: AuthType = .login
    @FocusState private var fieldIsFocused: Bool
    @State private var errorMessage = ""
    @State private var displayErrorMessage: Bool = false
    @State private var displayTOSSheet: Bool = false
    @State private var displayPPSheet: Bool = false
    @State private var isAuthenticating: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.4, blue: 0.4), // Warm red
                        Color(red: 0.95, green: 0.6, blue: 0.3)  // Warm orange
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Fun pattern overlay
                ZStack {
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 50...150))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
                .ignoresSafeArea()
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Logo/App name
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 60)
                                .foregroundColor(.white)
                            
                            Text("TerraTide")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 4) {
                                Text("Spontaneous meetups,")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("real connections")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, geometry.size.height * 0.08)
                        .padding(.bottom, 30)
                        // Hide logo when keyboard is shown
                        .opacity(keyboardHeight > 0 ? 0 : 1)
                        .frame(height: keyboardHeight > 0 ? 0 : nil)
                        
                        // Auth card
                        VStack(spacing: 20) {
                            // Error message
                            if !errorMessage.isEmpty && displayErrorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(10)
                            }
                            
                            PhoneEmailAuthView(
                                authType: self.authType,
                                fieldIsFocused: $fieldIsFocused,
                                errorMessage: $errorMessage,
                                displayErrorMessage: $displayErrorMessage,
                                displayTOSSheet: $displayTOSSheet,
                                displayPPSheet: $displayPPSheet,
                                isAuthenticating: $isAuthenticating
                            )
                            
                            Divider()
                                .padding(.vertical, 10)
                            
                            SwitchAuthView(authType: $authType)
                        }
                        .padding(25)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                        .padding(.horizontal)
                        
                        // Add bottom spacing to ensure content doesn't overflow into safe area
                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : max(geometry.safeAreaInsets.bottom + 20, 30))
                }
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                .onTapGesture {
                    fieldIsFocused = false
                }
            }
        }
        .edgesIgnoringSafeArea(.top) // Only ignore top safe area, respect bottom
        .sheet(isPresented: $displayTOSSheet) {
            TOSView()
        }
        .sheet(isPresented: $displayPPSheet) {
            PrivacyPolicyView()
        }
        .onAppear {
            // Clear any stale auth state on app launch
            if UserDefaults.standard.bool(forKey: "isReinstall") {
                try? Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "isReinstall")
            }
            
            // Add keyboard observers
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                keyboardHeight = keyboardFrame.height
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            // Remove keyboard observers
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}

struct PhoneEmailAuthView: View {
    var authType: AuthType = .login
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayForgotPasswordSheet: Bool = false
    var fieldIsFocused: FocusState<Bool>.Binding
    @Binding var errorMessage: String
    @Binding var displayErrorMessage: Bool
    @Binding var displayTOSSheet: Bool
    @Binding var displayPPSheet: Bool
    @Binding var isAuthenticating: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(authType == .login ? "Welcome Back" : "Create Account")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                    
                    TextField("email@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused(fieldIsFocused)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                    
                    SecureField("Password", text: $password)
                        .focused(fieldIsFocused)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            if authType == .login {
                Button {
                    displayForgotPasswordSheet = true
                } label: {
                    Text("Forgot password?")
                        .font(.footnote)
                        .foregroundColor(Color(red: 0.95, green: 0.4, blue: 0.4)) // Warm red
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical, 5)
            }
            
            // Login/Signup button
            Button {
                handleAuthentication()
            } label: {
                HStack {
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    
                    Text(authType == .login ? "Sign In" : "Create Account")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isAuthenticating ? Color.gray : Color(red: 0.95, green: 0.4, blue: 0.4)) // Warm red
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isAuthenticating)
            .buttonStyle(TapEffectButtonStyle())
            
            if authType == .signup {
                VStack(spacing: 5) {
                    Text("By joining you agree to our")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Button {
                            displayTOSSheet = true
                        } label: {
                            Text("Terms of Service")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.95, green: 0.4, blue: 0.4)) // Warm red
                        }
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            displayPPSheet = true
                        } label: {
                            Text("Privacy Policy")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.95, green: 0.4, blue: 0.4)) // Warm red
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .sheet(isPresented: $displayForgotPasswordSheet) {
            ForgotPasswordView()
        }
    }
    
    private func handleAuthentication() {
        isAuthenticating = true
        errorMessage = ""
        
        // Validate inputs
        if email.isEmpty || password.isEmpty {
            errorMessage = email.isEmpty ? "Please enter an email address." : "Please enter a password."
            displayErrorMessage = true
            isAuthenticating = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                displayErrorMessage = false
            }
            return
        }
        
        if authType == .signup && password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            displayErrorMessage = true
            isAuthenticating = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                displayErrorMessage = false
            }
            return
        }
        
        // Perform authentication
        if authType == .login {
            authViewModel.signInWithEmailAndPassword(email: email, password: password) { result in
                handleAuthResult(result: result)
            }
        } else {
            authViewModel.registerWithEmailAndPassword(email: email, password: password) { result in
                handleAuthResult(result: result)
            }
        }
    }
    
    private func handleAuthResult(result: Result<AuthDataResult, Error>) {
        switch result {
        case .success:
            Task { @MainActor in
                let status = await userViewModel.createUser()
                if !status {
                    errorMessage = "An error occurred while creating your user account. Try logging in!"
                    displayErrorMessage = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        displayErrorMessage = false
                    }
                }
            }
        case .failure(let error):
            isAuthenticating = false
            
            if let authError = error as? AuthErrorCode {
                switch authError {
                case .accountExistsWithDifferentCredential:
                    errorMessage = "This email address is already in use with a different sign-in method."
                case .userNotFound, .invalidCredential, .wrongPassword:
                    errorMessage = "Invalid email or password."
                case .emailAlreadyInUse:
                    errorMessage = "This email is already in use."
                case .invalidEmail:
                    errorMessage = "Invalid email address. Please check and try again."
                default:
                    errorMessage = "Authentication failed. Please try again later."
                }
            } else {
                errorMessage = "An error occurred. Please try again later."
            }
            
            displayErrorMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                displayErrorMessage = false
            }
        }
    }
}

struct SwitchAuthView: View {
    @Binding var authType: AuthType
    
    var body: some View {
        HStack(spacing: 4) {
            Text(authType == .login ? "Don't have an account?" : "Already have an account?")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button {
                withAnimation {
                    authType = authType == .login ? .signup : .login
                }
            } label: {
                Text(authType == .login ? "Sign Up" : "Sign In")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.95, green: 0.4, blue: 0.4)) // Warm red
            }
        }
    }
}

#Preview {
    AuthView()
}
