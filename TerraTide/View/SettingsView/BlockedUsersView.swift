//
//  BlockedUsersView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-25.
//

import SwiftUI

struct BlockedUsersView: View {
    @Binding var path: [Route]
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isUnblockingUser: Bool = false
    @State private var errorMessage: String = ""
    @State private var displayErrorMessage: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 20) {
                HStack {
                    Button {
                        path.removeAll { $0 == .general("blockedUsers") }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 50, height: 30, alignment: .leading)
                    
                    Spacer()
                    Text("Blocked Users")
                        .padding(.bottom, 10)
                    Spacer()
                    
                    Button {
                        path.removeAll { $0 == .general("blockedUsers") }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 50, height: 30, alignment: .leading)
                    .hidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView {
                    LazyVStack {
                        if let blockedUsers = userViewModel.user?.blockedUsers {
                            ForEach(blockedUsers.keys.sorted(), id: \.self) { blockedUserId in
                                if let username = blockedUsers[blockedUserId] {
                                    BlockedUserItemView(username: username, blockedUserId: blockedUserId, isUnblockingUser: $isUnblockingUser, errorMessage: $errorMessage, displayErrorMessage: $displayErrorMessage)
                                }
                            }
                        }
                    }
                }
            }
            
            Text(errorMessage)
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .font(.caption)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayErrorMessage ? 0 : -500)
                .frame(maxHeight: .infinity, alignment: .center)
                .opacity(displayErrorMessage ? 1 : 0)
                .animation(.easeInOut, value: displayErrorMessage)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct BlockedUserItemView: View {
    let username: String
    let blockedUserId: String
    @Binding var isUnblockingUser: Bool
    @Binding var errorMessage: String
    @Binding var displayErrorMessage: Bool
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var unblockWorkItem: DispatchWorkItem? = nil
    
    var body: some View {
        HStack {
            Text(username)
            Spacer()
            Button {
                Task { @MainActor in
                    unblockWorkItem?.cancel()
                    isUnblockingUser = true
                    let unblockStatus = await userViewModel.unblockUser(userId: userViewModel.user?.id ?? "", blockedUserId: blockedUserId)
                    
                    var isError = true
                    
                    switch unblockStatus {
                    case .alreadyUnblocked:
                        errorMessage = "This user has already been unblocked."
                    case .blockedUserNotFound:
                        errorMessage = "The user you are trying to unblock does not exist."
                    case .failed:
                        errorMessage = "An error occurred while unblocking the user."
                    case .missingData:
                        errorMessage = "Missing required data to unblock user. Try again soon!"
                    case .unblockingUserNotFound:
                        errorMessage = "We couldn't identify you. Please log in again."
                    case .unblocked:
                        isError = false
                    }
                    
                    if isError {
                        displayErrorMessage = true
                        
                        unblockWorkItem = DispatchWorkItem {
                            displayErrorMessage = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: unblockWorkItem!)
                    }
                    
                    isUnblockingUser = false
                }
            } label: {
                Text("Unblock")
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(isUnblockingUser ? .gray : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
            }
            .buttonStyle(TapEffectButtonStyle())
            .disabled(isUnblockingUser)
        }
        .padding(10)
        .background(LinearGradient(colors: [.orange, .indigo], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    BlockedUsersView(path: .constant([]))
}
