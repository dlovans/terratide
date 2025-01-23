//
//  AuthView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI

struct AuthView: View {
    @State private var authType: AuthType = .login
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                PresentationView()
                EmailPasswordView(authType: self.authType)
                AlternativeAuthView(authType: self.authType)
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

struct EmailPasswordView: View {
    var authType: AuthType = .login
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {
        VStack (spacing: 20) {
            Text(authType == .login ? "Login to TerraTide" : "Join TerraTide")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
            
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
            
            Button {
                if authType == .login {
                    print("Logging in")
                } else {
                    print("Joining TerraTide")
                }
            } label: {
                Text(authType == .login ? "Login" : "Join")
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
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct RemoveHighlightButtonStyle: ButtonStyle {
    @State private var buttonClicked = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(buttonClicked ? 0.9 : 1)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    buttonClicked = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        buttonClicked = false
                    }
                }
            }
    }
}


struct AlternativeAuthView: View {
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
