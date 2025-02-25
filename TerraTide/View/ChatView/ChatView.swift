//
//  ChatView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-09.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var actionFeedbackMessage: String = ""
    @State private var displayActionFeedbackMessage: Bool = false
    
    var chatFieldIsFocused: FocusState<Bool>.Binding
    
    var body: some View {
        ZStack {
            VStack {
                Text("Geo Chat")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                
                ScrollViewReader { reader in
                    ScrollView {
                        LazyVStack {
                            ForEach(chatViewModel.geoMessages) { message in
                                ChatMessageView(
                                    creatorUsername: message.sender,
                                    creatorId: message.byUserId,
                                    messageContent: message.text,
                                    messageId: message.id!,
                                    timeStamp: message.timestamp,
                                    actionFeedbackMessage: $actionFeedbackMessage,
                                    displayActionFeedbackMessage: $displayActionFeedbackMessage
                                )
                                .id(message.id)
                            }
                        }
                        .onChange(of: chatFieldIsFocused.wrappedValue) { _, newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation {
                                        if let lastMessageId = chatViewModel.geoMessages.last?.id {
                                            reader.scrollTo(lastMessageId)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 7)
                    .defaultScrollAnchor(.bottom)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.immediately)
                }
                
                ChatFieldView(chatFieldIsFocused: chatFieldIsFocused, actionFeedbackMessage: $actionFeedbackMessage, displayActionFeedbackMessage: $displayActionFeedbackMessage)
            }
            
            Text(actionFeedbackMessage)
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .font(.caption)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayActionFeedbackMessage ? 0 : -500)
                .animation(.easeInOut, value: displayActionFeedbackMessage)
                .frame(maxHeight: .infinity, alignment: .center)
                .opacity(displayActionFeedbackMessage ? 1 : 0)
        }
        .padding()
        .onAppear {
            if let userLocation = locationService.userLocation, let user = userViewModel.user {
                Task { @MainActor in
                    chatViewModel.attachGeoChatListener(userLocation: userLocation, blockedByUsers: user.blockedByUsers, blockedUsers: user.blockedUsers)
                }
            }
        }
        .onChange(of: locationService.userLocation) { _, newValue in
            if let userLocation = locationService.userLocation, let user = userViewModel.user {
                Task { @MainActor in
                    chatViewModel.attachGeoChatListener(userLocation: userLocation, blockedByUsers: user.blockedByUsers, blockedUsers: user.blockedUsers)
                }
            }
        }
        .onDisappear {
            Task { @MainActor in
                chatViewModel.removeGeoChatListener()
                print("Geo chat listener destroyed")
                
            }
        }
    }
}

struct ChatMessageView: View {
    let creatorUsername: String
    let creatorId: String
    let messageContent: String
    let messageId: String
    let timeStamp: Date
    
    @Binding var actionFeedbackMessage: String
    @Binding var displayActionFeedbackMessage: Bool
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var displayGeoMessageReportSheet: Bool = false
    @State private var displayBlockingAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if userViewModel.user?.id != creatorId {
                    Spacer()
                    Text(timeStamp, style: .time)
                        .font(.footnote)
                }
                Text("\(creatorUsername): \(messageContent)")
                    .font(.subheadline)
                    .frame(
                        minWidth: 0,
                        maxWidth: UIScreen.main.bounds.width * 0.6,
                        alignment: .topLeading
                    )
                    .padding()
                    .background(userViewModel.user?.id == creatorId ? .green.opacity(0.3) : .orange.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        if userViewModel.user?.id != creatorId {
                            Button {
                                displayGeoMessageReportSheet = true
                            } label: {
                                Text("Report")
                            }
                            Button {
                                displayBlockingAlert = true
                            } label: {
                                Text("Block \(creatorUsername)")
                            }
                        }
                    }
                    .sheet(isPresented: $displayGeoMessageReportSheet) {
                        ReportView(reportType: .geoMessage, messageId: messageId, messageCreatorUsername: creatorUsername, reportByUserId: userViewModel.user?.id ?? "", reportAgainstUserId: creatorId, showReportSheet: $displayGeoMessageReportSheet)
                    }
                    .alert("Blocking this user will hide their Tides and messages.", isPresented: $displayBlockingAlert) {
                        Button(role: .cancel) {
                            displayBlockingAlert = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.black)
                                .background(.blue)
                        }
                        Button(role: .destructive) {
                            Task { @MainActor in
                                let blockStatus = await userViewModel.blockUser(blocking: creatorId, againstUsername: creatorUsername, by: userViewModel.user?.id ?? "")
                                
                                switch blockStatus {
                                case .blocked:
                                    actionFeedbackMessage = "User blocked!"
                                case .failed:
                                    actionFeedbackMessage = "Failed to block user."
                                case .alreadyBlocked:
                                    actionFeedbackMessage = "This user is already blocked."
                                case .missingData:
                                    actionFeedbackMessage = "Something went wrong. Please try again later."
                                case .userBlockingNotFound:
                                    actionFeedbackMessage = "Could not find the user you are trying to block."
                                case .userToBlockNotFound:
                                    actionFeedbackMessage = "You aren't authorized. Please try again later."
                                }
                                
                                displayActionFeedbackMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    displayActionFeedbackMessage = false
                                }
                            }
                        } label: {
                            Text("Block \(creatorUsername)")
                        }
                    } message: {
                        Text("\n1. You won't see their Tides or messages anymore.\n\n2. You'll still be able to join the same Tides as long as neither of you are the creators.")
                    }
                
                
                if userViewModel.user?.id == creatorId {
                    Text(timeStamp, style: .time)
                        .font(.footnote)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
        }
    }
}
struct ChatFieldView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var locationService: LocationService
    @State private var messageContent: String = ""
    @State private var isSendingMessage: Bool = false
    @State private var messageWorkItem: DispatchWorkItem?
    
    var chatFieldIsFocused: FocusState<Bool>.Binding
    @Binding var actionFeedbackMessage: String
    @Binding var displayActionFeedbackMessage: Bool
    
    var body: some View {
        HStack {
            TextField("", text: $messageContent, axis: .vertical)
                .focused(chatFieldIsFocused)
                .lineLimit(4)
                .padding()
                .onChange(of: messageContent) { _, newValue in
                    if newValue.count > 250 {
                        messageContent = String(newValue.prefix(250))
                    }
                }
            
            Button {
                Task { @MainActor in
                    messageWorkItem?.cancel()
                    displayActionFeedbackMessage = false
                    isSendingMessage = true
                    
                    if !messageContent.isEmpty {
                        if let user = userViewModel.user, let boundingBox = locationService.boundingBox {
                            let status = await chatViewModel.createGeoMessage(
                                text: self.messageContent.trimmingCharacters(in: .whitespacesAndNewlines),
                                sender: user.username,
                                userId: user.id,
                                boundingBox: boundingBox
                            )
                            
                            var isError = true
                            
                            switch status {
                            case .sent:
                                isError = false
                                messageContent = ""
                            case .emptyMessage:
                                actionFeedbackMessage = "Message can't be empty."
                            case .failedToCreate:
                                actionFeedbackMessage = "Failed to create message."
                            case .invalidLocation:
                                actionFeedbackMessage = "Invalid location. Please check your location settings."
                            default:
                                print("Unknown error occurred! Sorry :(")
                                actionFeedbackMessage = "Unknown error occurred! Sorry :("
                            }
                            
                            if isError {
                                displayActionFeedbackMessage = true
                                
                                messageWorkItem = DispatchWorkItem {
                                    displayActionFeedbackMessage = false
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: messageWorkItem!)
                            }
                        }
                    }
                    
                    isSendingMessage = false
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .padding(.trailing, 10)
                    .foregroundStyle(isSendingMessage ? .gray : .orange)
                    .opacity(messageContent.isEmpty ? 0 : 1)
            }
            .disabled(isSendingMessage)
        }
        .padding(.horizontal,5)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 2)
        }
    }
}
