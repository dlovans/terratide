//
//  AuthView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var authType: AuthType = .login
    @State private var isEmailAuth: Bool = true
    @State private var errorMessage = ""
    @State private var displayErrorMessage: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                PresentationView()
                PhoneEmailAuthView(authType: self.authType, isEmailAuth: $isEmailAuth, errorMessage: $errorMessage, displayErrorMessage: $displayErrorMessage)
                AlternativeAuthView(isEmailAuth: $isEmailAuth, authType: self.authType)
                SwitchAuthView(authType: $authType)
            }
        }
    }
}

struct PresentationView: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 100)
            .overlay {
                Circle()
                    .frame(width: 900, height: 900)
                    .foregroundStyle(LinearGradient(colors: [.indigo, .orange], startPoint: .top, endPoint: .bottom))
                
            }
        
            .foregroundStyle(.clear)
            .offset(y: -400)
            .overlay {
                Text("TerraTide")
                    .font(.headline)
            }
    }
}

struct PhoneEmailAuthView: View {
    var authType: AuthType = .login
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @Binding var isEmailAuth: Bool
    @Binding var errorMessage: String
    @Binding var displayErrorMessage: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            Text(authType == .login ? "Login to TerraTide" : "Join TerraTide")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
            
            Text(errorMessage)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 30)
                .foregroundStyle(.white)
                .padding(10)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayErrorMessage ? 0 : -500)
            
            if isEmailAuth {
                VStack {
                    Text("Email")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $email)
                        .accessibilityHint(Text("Enter your email address."))
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.orange, lineWidth: 1)
                        }
                        .overlay {
                            if email.isEmpty {
                                Text("email@example.com")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 18)
                                    .allowsHitTesting(false)
                                    .tint(.indigo)
                                    .opacity(0.6)
                            }
                        }
                }
                
                VStack {
                    Text("Password")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SecureField("", text: $password)
                        .accessibilityHint(Text("Enter your password."))
                        .keyboardType(.default)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.orange, lineWidth: 1)
                        }
                        .overlay {
                            if password.isEmpty {
                                Text("Password")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 18)
                                    .allowsHitTesting(false)
                                    .foregroundStyle(.indigo)
                                    .opacity(0.6)
                            }
                        }
                }
            } else {
                // Phone auth
                VStack {
                    Text("Phone")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $phoneNumber)
                        .padding()
                        .keyboardType(.phonePad)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.orange, lineWidth: 1)
                        }
                        .overlay {
                            if phoneNumber.isEmpty {
                                Text("+46728652474")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 18)
                                    .allowsHitTesting(false)
                                    .foregroundStyle(.indigo)
                                    .opacity(0.6)
                                    
                            }
                        }
                }
            }
            
            Button {
                if email.isEmpty || password.isEmpty || password.count < 6 {
                    if email.isEmpty {
                        errorMessage = "Please enter an email address."
                    } else if password.isEmpty {
                        errorMessage = "Please enter a password."
                    } else if password.count < 6 {
                        errorMessage = "Password must be at least 6 characters long."
                    }
                    
                    withAnimation {
                        displayErrorMessage = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            displayErrorMessage = false
                        }
                    }
                    return
                }
                
                if authType == .login {
                    authViewModel.signInWithEmailAndPassword(email: email, password: password) { result in
                        switch result {
                            case .success:
                            Task { @MainActor in
                                // In case user was created with FirebaseAuth but not in Firestore
                                let status = await userViewModel.createUser()
                                if status {
                                    userViewModel.attachUserListener()
                                } else {
                                    errorMessage = "An error occurred while creating your user account. Try logging in!"
                                    withAnimation {
                                        displayErrorMessage = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        withAnimation {
                                            displayErrorMessage = false
                                        }
                                    }
                                }
                            }
                                
                            case .failure(let error):
                            if let authError = error as? AuthErrorCode {
                                switch authError {
                                case .accountExistsWithDifferentCredential:
                                    errorMessage = "This email address is already in use. Try logging in with Google or Apple."
                                case .userNotFound:
                                    errorMessage = "This email address is not registered. Try signing up."
                                case .emailAlreadyInUse:
                                    errorMessage = "You're already logged in. Delete local app data and try again."
                                case .invalidEmail:
                                    errorMessage = "Invalid email address. Check your spelling and try again."
                                case .weakPassword:
                                    errorMessage = "Password must be at least 6 characters long."
                                case .missingEmail:
                                    errorMessage = "Email address is required."
                                case .wrongPassword:
                                    errorMessage = "Wrong email or password"
                                default:
                                    errorMessage = "An error occurred"
                                }
                            } else {
                                errorMessage = "An error occurred while logging in. Try again later."
                            }
                            withAnimation {
                                displayErrorMessage = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    displayErrorMessage = false
                                }
                            }
                        }
                    }
                } else {
                    authViewModel.registerWithEmailAndPassword(email: email, password: password) { result in
                        switch result {
                        case .success:
                            Task { @MainActor in
                                let status = await userViewModel.createUser()
                                if status {
                                    userViewModel.attachUserListener()
                                } else {
                                    errorMessage = "An error occurred while creating your user account. Try logging in!"
                                    withAnimation {
                                        displayErrorMessage = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        withAnimation {
                                            displayErrorMessage = false
                                        }
                                    }                                    }
                            }
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            } label: {
                Text(isEmailAuth ? authType == .login ? "Login" : "Join" : "Send code")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .opacity(0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
            }
            .buttonStyle(RemoveHighlightButtonStyle())
            
            .accessibilityHint(Text("Click to \(authType == .login ? "login" : "join")."))
            
        }
        .padding()
    }
}

struct RemoveHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct AlternativeAuthView: View {
    @Binding var isEmailAuth: Bool
    
    var authType: AuthType = .login
    
    var body: some View {
        VStack (spacing: 20) {
            ZStack {
                Rectangle()
                    .foregroundColor(.orange)
                    .opacity(0.9)
                    .frame(maxWidth: .infinity, maxHeight: 2)
                Text("Or")
                    .padding(.horizontal, 5)
                    .background(Color.white)
            }
            
            VStack {
//                Button {
//                    withAnimation {
//                        isEmailAuth.toggle()
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: isEmailAuth ? "phone" : "mail")
//                        Text("\(authType == .login ? "Continue with" : "Signup with") \(isEmailAuth ? "Phone Number" : "Email")")
//                    }
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(.black)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//                .buttonStyle(RemoveHighlightButtonStyle())
                
                Button {
                    if authType == .login {
                        print("Logging in with Apple")
                    } else {
                        print("Joining TerraTide with Apple")
                    }
                } label: {
                        HStack {
                            Image(systemName: "applelogo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(authType == .login ? "Continue with Apple" : "Signup with Apple")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(RemoveHighlightButtonStyle())
                
                Button {
                    if authType == .login {
                        print("Logging in with Google")
                    } else {
                        print("Joining TerraTide with Google")
                    }
                } label: {
                    HStack {
                        Image("googlelogo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(authType == .login ? "Continue with Google" : "Signup with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(RemoveHighlightButtonStyle())
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct SwitchAuthView: View {
    @Binding var authType: AuthType
    
    var body: some View {
        HStack {
            Text(authType == .login ? "Don't have an account?": "Already got an account?")
            Button {
                if authType == .login {
                    authType = .signup
                } else {
                    authType = .login
                }
            } label: {
                Text(authType == .login ? "Join" : "Login")
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    AuthView()
}
