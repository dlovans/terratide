//
//  TidePageView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct TidePageView: View {
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @Binding var path: [Route]
    @State private var displayChat: Bool = true
    
    let tideId: String
    
    var body: some View {
        ZStack {
            if !singleTideViewModel.tideHasLoaded && !singleTideViewModel.tideChatHasLoaded {
                LoadingView()
            } else {
                VStack {
                    HStack {
                        Button {
                            path.removeAll { $0 == .tide(tideId) }
                        } label: {
                            Image(systemName: "arrow.backward")
                                .foregroundStyle(.black)
                        }
                        .frame(width: 50, height: 30, alignment: .leading)
                        
                        Spacer()
                        Text(singleTideViewModel.tide?.title ?? "")
                        Spacer()
                        
                        Group {
                            Button {
                                withAnimation {
                                    displayChat.toggle()
                                }
                            } label: {
                                Image(systemName: displayChat ? "gear" : "bubble.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .frame(width: 50, height: 30, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if displayChat {
                        VStack {
                            if chatViewModel.tideChatHasLoaded {
                                TideChatView()
                            } else {
                                LoadingView()
                            }
                        }
                        .onAppear {
                            Task { @MainActor in
                                if !chatViewModel.tideChatHasLoaded {
                                    chatViewModel.attachTideChatListener(
                                        tideId: singleTideViewModel.tide?.id ?? "",
                                        blockedByUsers: userViewModel.user?.blockedByUsers ?? [],
                                        blockedUsers: userViewModel.user?.blockedUsers ?? [:]
                                    )
                                }
                            }
                        }
                    } else {
                        TideDetailsView()
                        ShareTideView()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task { @MainActor in
                if !singleTideViewModel.tideHasLoaded {
                    singleTideViewModel.attachTideListener(tideId: tideId)
                }
            }
        }
        .onDisappear {
            Task { @MainActor in
                chatViewModel.removeTideChatListener()
                singleTideViewModel.removeTideListener()
            }
        }
    }
}

struct TideDetailsView: View {
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var actionFeedbackMessage: String = ""
    @State private var displayActionFeedbackMessage: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 10) {
                    HStack {
                        Text("Creator:")
                        Spacer()
                        Text(singleTideViewModel.tide?.creatorUsername ?? "")
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Tide Size:")
                        Spacer()
                        Text("\(singleTideViewModel.tide?.participantCount ?? 1)/\(singleTideViewModel.tide?.maxParticipants ?? 10)")
                    }
                    
                    Text(singleTideViewModel.tide?.description ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack {
                        Text("Members:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 3), spacing: 10) {
                                
                                TideMemberView(userId: singleTideViewModel.tide?.creatorId ?? "", username: singleTideViewModel.tide?.creatorUsername ?? "", actionFeedbackMessage: $actionFeedbackMessage, displayActionFeedbackMessage: $displayActionFeedbackMessage)
                                if let memberIds = singleTideViewModel.tide?.members {
                                    ForEach(memberIds.keys.sorted().filter { $0 != singleTideViewModel.tide?.creatorId ?? ""}, id: \.self) { memberId in
                                        if let memberUsername = memberIds[memberId] {
                                            TideMemberView(userId: memberId, username: memberUsername, actionFeedbackMessage: $actionFeedbackMessage, displayActionFeedbackMessage: $displayActionFeedbackMessage)
                                        }
                                    }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                }
            }
            Text(actionFeedbackMessage)
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .font(.caption)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayActionFeedbackMessage ? 0 : -500)
                .frame(maxHeight: .infinity, alignment: .center)
                .opacity(displayActionFeedbackMessage ? 1 : 0)
                .animation(.easeInOut, value: displayActionFeedbackMessage)
            
        }
    }
}

struct TideMemberView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var displayBlockingAlert: Bool = false
    
    let userId: String
    let username: String
    @Binding var actionFeedbackMessage: String
    @Binding var displayActionFeedbackMessage: Bool
    
    var body: some View {
        Text(username)
            .fixedSize(horizontal: true , vertical: false)
            .padding(10)
            .background(userViewModel.user?.id == userId ? .black : .orange.opacity(0.3))
            .foregroundStyle(userViewModel.user?.id == userId ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                        let blockStatus = await userViewModel.blockUser(blocking: userId, againstUsername: username, by: userViewModel.user?.id ?? "")
                        
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
                    Text("Block \(username)")
                }
            } message: {
                Text("\n1. You won't see their Tides or messages anymore.\n\n2. You'll still be able to join the same Tides as long as neither of you are the creators.")
            }
    }
    
}

struct ShareTideView: View {
    var body: some View {
        ShareLink(item: URL(string: "https://www.google.com")!) {
            Label("Share Tide", systemImage: "square.and.arrow.up")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundStyle(.white)
        .background(.orange.opacity(0.7))
        .buttonStyle(TapEffectButtonStyle())
        .cornerRadius(10)
    }
}

struct TideChatView: View {
    @FocusState private var chatFieldIsFocused: Bool
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @State private var actionFeedbackMessage: String = ""
    @State private var displayActionFeedbackMessage: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { reader in
                    ScrollView {
                        LazyVStack {
                            ForEach(chatViewModel.tideMessages) { message in
                                TideChatMessageView(
                                    creatorUsername: message.sender,
                                    creatorId: message.byUserId,
                                    messageContent: message.text,
                                    timeStamp: message.timestamp,
                                    actionFeedbackMessage: $actionFeedbackMessage,
                                    displayActionFeedbackMessage: $displayActionFeedbackMessage
                                )
                                .id(message.id)
                            }
                        }
                        .onChange(of: chatFieldIsFocused) { _, newValue in
                            print(chatFieldIsFocused)
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation {
                                        reader.scrollTo(chatViewModel.tideMessages.last?.id)
                                    }
                                }
                            }
                        }
                    }
                    .defaultScrollAnchor(.bottom)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
                
                TideChatFieldView(chatFieldIsFocused: $chatFieldIsFocused, actionFeedbackMessage: $actionFeedbackMessage, displayActionFeedbackMessage: $displayActionFeedbackMessage)
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
    }
}

struct TideChatMessageView: View {
    let creatorUsername: String
    let creatorId: String
    let messageContent: String
    let timeStamp: Date
    @Binding var actionFeedbackMessage: String
    @Binding var displayActionFeedbackMessage: Bool
    
    @State private var showReportMessageSheet: Bool = false
    @State private var showBlockingAlert: Bool = false
    @EnvironmentObject private var userViewModel: UserViewModel
    
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
                    .background(userViewModel.user?.id != creatorId ? .green.opacity(0.3) : .orange.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        if userViewModel.user?.id != creatorId {
                            Button {
                                showReportMessageSheet = true
                            } label: {
                                Text("Report")
                            }
                            Button {
                                showBlockingAlert = true
                            } label: {
                                Text("Block User")
                            }
                        }
                    }
                    .sheet(isPresented: $showReportMessageSheet) {
                        Text("Reporting message....")
                    }
                    .alert("Blocking this user will hide their Tides and messages.", isPresented: $showBlockingAlert) {
                        Button(role: .cancel) {
                            showBlockingAlert = false
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

struct TideChatFieldView: View {
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
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
                    
                    let status = await chatViewModel.createTideMessage(
                        tideId: singleTideViewModel.tide?.id ?? "",
                        text: messageContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        sender: userViewModel.user?.username ?? "",
                        userId: userViewModel.user?.id ?? ""
                    )
                    
                    var isError = true
                    
                    switch status {
                    case .emptyMessage:
                        actionFeedbackMessage = "Message cannot be empty."
                    case .failedToCreate:
                        actionFeedbackMessage = "Failed to send message :("
                    case .invalidData:
                        actionFeedbackMessage = "Something went wrong while creating the message."
                    case .sent:
                        isError = false
                        messageContent = ""
                    default:
                        print("Unknown error occurred.")
                        actionFeedbackMessage = "Unknown error occurred!"
                    }
                    
                    if isError {
                        displayActionFeedbackMessage = true
                        
                        messageWorkItem = DispatchWorkItem {
                            displayActionFeedbackMessage = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: messageWorkItem!)
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

#Preview {
    TidePageView(path: .constant([]), tideId: "123")
}
