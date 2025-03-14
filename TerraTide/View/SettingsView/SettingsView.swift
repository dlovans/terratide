//
//  SettingsView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-09.
//

import SwiftUI

struct SettingsView: View {
    @Binding var path: [Route]
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var tidesViewModel: TidesViewModel
    @State private var displayFeedbackSheet: Bool = false
    @State private var displayErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    @State private var errorWorkItem: DispatchWorkItem?
    @State private var disableButtons: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Settings")
                Button {
                    displayFeedbackSheet = true
                } label: {
                    HStack {
                        Text("Feedback")
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(disableButtons ? .gray : .green.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(TapEffectButtonStyle())
                .disabled(disableButtons)
                
                Button {
                    path.append(.general("blockedUsers"))
                } label: {
                    HStack {
                        Text("Blocked Users")
                        Image(systemName: "arrow.forward")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(disableButtons ? .gray : .red.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(TapEffectButtonStyle())
                .disabled(disableButtons)
                
                Button {
                    disableButtons = true
                    
                    if authViewModel.signOut() == .logoutFailure {
                        errorWorkItem?.cancel()
                        errorMessage = "Failed to logout. Restart app or try again later."
                        displayErrorMessage = true
                        disableButtons = false
                        
                        errorWorkItem = DispatchWorkItem {
                            withAnimation {
                                displayErrorMessage = false
                                errorMessage = ""
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: errorWorkItem!)
                    }
                } label: {
                    HStack {
                        Text("Logout")
                        Image(systemName: "square.and.arrow.down")
                            .rotationEffect(.degrees(-90))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(disableButtons ? .gray : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(TapEffectButtonStyle())
                .disabled(disableButtons)
                
                Spacer()
                
                DeleteAccountView(path: $path)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            
            Text(errorMessage)
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .font(.caption)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayErrorMessage ? 0 : -500)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .opacity(displayErrorMessage ? 1 : 0)
                .animation(.easeInOut, value: displayErrorMessage)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $displayFeedbackSheet) {
            FeedbackView(showFeedbackSheet: $displayFeedbackSheet)
        }
    }
}

#Preview {
    SettingsView(path: .constant([]))
}
