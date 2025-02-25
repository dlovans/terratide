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
    @State private var authType: AuthType = .login
    @FocusState private var fieldIsFocused: Bool
    @State private var isEmailAuth: Bool = true
    @State private var errorMessage = ""
    @State private var displayErrorMessage: Bool = false
    
    var body: some View {
        ZStack {
            Color.clear
                .background(LinearGradient(colors: [.orange, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea()
                .onTapGesture {
                    fieldIsFocused = false
                }
            VStack (spacing: 30) {
                PhoneEmailAuthView(authType: self.authType, fieldIsFocused: $fieldIsFocused, isEmailAuth: $isEmailAuth, errorMessage: $errorMessage, displayErrorMessage: $displayErrorMessage)
                AlternativeAuthView(isEmailAuth: $isEmailAuth, authType: self.authType)
                    .onTapGesture {
                        fieldIsFocused = false
                    }
                Spacer()
                SwitchAuthView(authType: $authType)
                    .onTapGesture {
                        fieldIsFocused = false
                    }
            }
            .padding()
            .onTapGesture {
                fieldIsFocused = false
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            chatViewModel.removeGeoChatListener()
            chatViewModel.removeTideChatListener()
            tidesViewModel.removeActiveTidesListener()
            tidesViewModel.removeAvailableTidesListener()
            singleTideViewModel.removeTideListener()
        }
        .onTapGesture {
            fieldIsFocused = false
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
    var fieldIsFocused: FocusState<Bool>.Binding
    @Binding var isEmailAuth: Bool
    @Binding var errorMessage: String
    @Binding var displayErrorMessage: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            Text(authType == .login ? "Login to TerraTide" : "Join TerraTide")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
            
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
                        .focused(fieldIsFocused)
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
                        .focused(fieldIsFocused)
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
                        .focused(fieldIsFocused)
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
                if email.isEmpty || password.isEmpty {
                    if email.isEmpty {
                        errorMessage = "Please enter an email address."
                    } else if password.isEmpty {
                        errorMessage = "Please enter a password."
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
                                if !status {
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
                                case .userNotFound, .invalidCredential, .wrongPassword:
                                    errorMessage = "Invalid email or password."
                                case .emailAlreadyInUse:
                                    errorMessage = "You're already logged in. Delete local app data and try again."
                                case .invalidEmail:
                                    errorMessage = "Invalid email address. Check your spelling and try again."
                                default:
                                    errorMessage = "An error occurred while trying to log in. Try again later."
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
                                if !status {
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
            .buttonStyle(TapEffectButtonStyle())
            .accessibilityHint(Text("Click to \(authType == .login ? "login" : "join")."))
        }
    }
}

struct AlternativeAuthView: View {
    @Binding var isEmailAuth: Bool
    
    var authType: AuthType = .login
    
    var body: some View {
        VStack (spacing: 20) {
                HStack {
                    Rectangle()
                        .foregroundStyle(LinearGradient(colors: [.clear, .orange], startPoint: .leading, endPoint: .trailing))
                        .opacity(0.9)
                        .frame(maxWidth: .infinity, maxHeight: 2)
                    Text("Or")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                    Rectangle()
                        .foregroundStyle(LinearGradient(colors: [.orange, .clear], startPoint: .leading, endPoint: .trailing))
                        .opacity(0.9)
                        .frame(maxWidth: .infinity, maxHeight: 2)
                }
                .padding(.bottom, 5)
            
            VStack {
                Button {
                    withAnimation {
                        isEmailAuth.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: isEmailAuth ? "phone" : "mail")
                        Text("\(authType == .login ? "Continue with" : "Signup with") \(isEmailAuth ? "Phone Number" : "Email")")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(TapEffectButtonStyle())
                
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
                .buttonStyle(TapEffectButtonStyle())
                
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
                .buttonStyle(TapEffectButtonStyle())
            }
        }
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
