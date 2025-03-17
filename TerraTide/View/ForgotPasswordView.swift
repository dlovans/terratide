//
//  ForgotPasswordView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-04.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var isSending: Bool = false
    @State private var message: String = ""
    @State private var showMessage: Bool = false
    @State private var messageIsError: Bool = false
    
    // Adaptive colors based on color scheme
    private var gradientColors: [Color] {
        colorScheme == .dark ? 
            [Color(red: 0.7, green: 0.3, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.2)] : 
            [Color(red: 0.95, green: 0.4, blue: 0.4), Color(red: 0.95, green: 0.6, blue: 0.3)]
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemBackground)
    }
    
    private var inputBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground)
    }
    
    private var primaryButtonColor: Color {
        colorScheme == .dark ? Color(red: 0.7, green: 0.3, blue: 0.3) : Color(red: 0.95, green: 0.4, blue: 0.4)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.primary
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.secondary
    }
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("We'll send you a password reset link")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)
                
                // Card
                VStack(spacing: 20) {
                    // Message
                    if !message.isEmpty && showMessage {
                        Text(message)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(messageIsError ? 
                                        (colorScheme == .dark ? Color.red.opacity(0.2) : Color.red.opacity(0.1)) : 
                                        (colorScheme == .dark ? Color.green.opacity(0.2) : Color.green.opacity(0.1)))
                            .foregroundColor(messageIsError ? .red : .green)
                            .cornerRadius(10)
                    }
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(secondaryTextColor)
                            
                            TextField("email@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .foregroundColor(textColor)
                        }
                        .padding()
                        .background(inputBackgroundColor)
                        .cornerRadius(12)
                    }
                    
                    // Reset button
                    Button {
                        resetPassword()
                    } label: {
                        HStack {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSending ? Color.gray : primaryButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || isSending)
                    .buttonStyle(TapEffectButtonStyle())
                    
                    // Cancel button
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(primaryButtonColor)
                    }
                    .padding(.top, 5)
                }
                .padding(25)
                .background(cardBackgroundColor)
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? 
                        Color.black.opacity(0.3) : Color.black.opacity(0.15), 
                        radius: 15, x: 0, y: 8)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            message = "Please enter your email address"
            messageIsError = true
            showMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showMessage = false
            }
            return
        }
        
        isSending = true
        
        authViewModel.sendPasswordResetLink(to: email) { success in
            isSending = false
            
            if success {
                message = "Password reset email sent. Check your inbox."
                messageIsError = false
            } else {
                message = "Error sending password reset email. Please try again."
                messageIsError = true
            }
            
            showMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if !messageIsError {
                    dismiss()
                } else {
                    showMessage = false
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .preferredColorScheme(.light)
}

#Preview {
    ForgotPasswordView()
        .preferredColorScheme(.dark)
}
