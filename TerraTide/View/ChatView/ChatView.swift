//
//  ChatView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-09.
//

import SwiftUI

struct ChatView: View {
    let chatId: String = "123"
    
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @FocusState private var chatFieldIsFocused: Bool
    
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
                                    createdBy: message.sender,
                                    messageContent: message.text,
                                    timeStamp: message.timestamp
                                )
                                .id(message.id)
                            }
                        }
                        .onChange(of: chatFieldIsFocused) { _, newValue in
                            print(chatFieldIsFocused)
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
                
                ChatFieldView(chatFieldIsFocused: $chatFieldIsFocused)
            }
        }
        .padding()
        .onAppear {
            if let userLocation = locationService.userLocation {
                Task { @MainActor in
                    chatViewModel.attachChatListener(userLocation: userLocation)
                }
            }
        }
        .onChange(of: locationService.userLocation) { _, newValue in
            if let userLocation = locationService.userLocation {
                Task {
                    chatViewModel.attachChatListener(userLocation: userLocation)
                }
            }
        }
        .onDisappear {
            Task {
                chatViewModel.removeChatListener()
            }
            print("Geo chat listener destroyed")
        }
    }
}

struct ChatMessageView: View {
    let createdBy: String
    let messageContent: String
    let timeStamp: Date
    
    let mockSelfUser = "You"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if mockSelfUser != createdBy {
                    Spacer()
                    Text(timeStamp, style: .time)
                        .font(.footnote)
                }
                Text("\(createdBy): \(messageContent)")
                    .font(.subheadline)
                    .frame(
                        minWidth: 0,
                        maxWidth: UIScreen.main.bounds.width * 0.6,
                        alignment: .topLeading
                    )
                    .padding()
                    .background(mockSelfUser == createdBy ? .green.opacity(0.3) : .orange.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        Button {
                            // Report msg
                        } label: {
                            Text("Report")
                        }
                    }
                
                if mockSelfUser == createdBy {
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
    var chatFieldIsFocused: FocusState<Bool>.Binding
    
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
                if !messageContent.isEmpty {
                    if let user = userViewModel.user, let boundingBox = locationService.boundingBox {
                        Task { @MainActor in
                            let status = await chatViewModel.createMessage(
                                text: self.messageContent,
                                sender: user.username,
                                userId: user.id,
                                boundingBox: boundingBox
                            )
                            
                            switch status {
                            case .emptyMessage:
                                print("Message can't be empty.")
                            case .failedToCreate:
                                print("Failed to create message.")
                            case .invalidLocation:
                                print("Invalid location!")
                            case .sent:
                                print("Message was sent!")
                                messageContent = ""
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .padding(.trailing, 10)
                    .foregroundStyle(.orange)
                    .opacity(messageContent.isEmpty ? 0 : 1)
            }
        }
        .padding(.horizontal,5)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 2)
        }
    }
}

#Preview {
    ChatView()
}
