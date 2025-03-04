//
//  ForgotPasswordView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-04.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var isSending: Bool = false
    @State private var linkSent: Bool = false
    @State private var actionText: String = ""
    var body: some View {
        ZStack {
            Color.clear
                .background(LinearGradient(colors: [.orange, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea()
            VStack {
                Text("Forgot Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                
                VStack {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.orange, lineWidth: 1)
                        }
                    
                    Button {
                        Task { @MainActor in
                            isSending = true
                                                    
                            authViewModel.sendPasswordResetLink(to: email) { result in
                                if result {
                                    actionText = "Check your email for a link to reset your password."
                                    linkSent = true
                                } else {
                                    actionText = "An error occurred. Please try again."
                                    linkSent = false
                                }
                            }
                            
                            isSending = false
                        }
                    } label: {
                        Text("Reset Password")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(email.isEmpty || isSending || linkSent ? .gray : .orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    .disabled(email.isEmpty || isSending || linkSent)
                    
                    Text(actionText)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.top, -60)
            }
            .padding()
        }
    }
}

#Preview {
    ForgotPasswordView()
}
