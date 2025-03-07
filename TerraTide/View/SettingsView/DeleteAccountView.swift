//
//  DeleteAccountView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-07.
//

import SwiftUI

struct DeleteAccountView: View {
    @Binding var path: [Route]
    @State private var deleteAccountButtonText: String = "Delete Account"
    
    var body: some View {
        VStack {
            ZStack {
                Button {
                    path.append(.general("deleteAccount"))
                } label: {
                    Text(deleteAccountButtonText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.red)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(TapEffectButtonStyle())
            }
        }
    }
}

struct DeleteAccountConfirmationView: View {
    @Binding var path: [Route]
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var disableButtons: Bool = false
    @State private var deleteAccountButtonText: String = "Delete Account"
    @State private var displayAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(deleteAccountButtonText)
                .font(.headline)
            Text("By deleting your account, you will free up your username for others.")
            Text("This action cannot be undone.")
            
            Button {
                path.removeLast()
            } label: {
                Text("Cancel")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(disableButtons ? .gray : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(TapEffectButtonStyle())
            .disabled(disableButtons)
            
            Button {
                Task { @MainActor in
                    disableButtons = true
                    deleteAccountButtonText = "Deleting..."
                    let status = await userViewModel.deleteAccount(userId: userViewModel.user?.id ?? "")
                    
                    if !status {
                        deleteAccountButtonText = "Failed to delete account. Try again."
                        disableButtons = false
                    } else {
                        deleteAccountButtonText = "Account deleted!"
                        
                    }
                }
            } label: {
                Text(deleteAccountButtonText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(disableButtons ? .gray : .black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(TapEffectButtonStyle())
            .disabled(disableButtons)
        }
        .padding()
    }
}

