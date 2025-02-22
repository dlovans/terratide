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
                                    chatViewModel.attachTideChatListener(tideId: singleTideViewModel.tide?.id ?? "")
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
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack {
                    Text("Creator:")
                    Spacer()
                    Text("Dlovan")
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
                
                            TideMemberView(userId: singleTideViewModel.tide?.creatorId ?? "", username: singleTideViewModel.tide?.creatorUsername ?? "")
                            if let memberIds = singleTideViewModel.tide?.members {
                                ForEach(memberIds.keys.sorted().filter { $0 != singleTideViewModel.tide?.creatorId ?? ""}, id: \.self) { memberId in
                                    if let memberUsername = memberIds[memberId] {
                                        TideMemberView(userId: memberId, username: memberUsername)
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
    }
}

struct TideMemberView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showReportUserSheet: Bool = false

    let userId: String
    let username: String
    
    var body: some View {
        Text(username)
            .fixedSize(horizontal: true , vertical: false)
            .padding(10)
            .background(userViewModel.user?.id == userId ? .black : .orange.opacity(0.3))
            .foregroundStyle(userViewModel.user?.id == userId ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                Button {
                    showReportUserSheet = true
                } label: {
                    HStack {
                        Text("Report")
                    }
                }
            }
            .sheet(isPresented: $showReportUserSheet) {
                Text(username)
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
        .buttonStyle(RemoveHighlightButtonStyle())
        .cornerRadius(10)
    }
}

struct TideChatView: View {
    @FocusState private var chatFieldIsFocused: Bool
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
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
                
                TideChatFieldView(chatFieldIsFocused: $chatFieldIsFocused)
            }
        }
    }
}

struct TideChatMessageView: View {
    let creatorUsername: String
    let creatorId: String
    let messageContent: String
    let timeStamp: Date
        
    @State private var showReportMessageSheet: Bool = false
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
                        Button {
                            showReportMessageSheet = true
                        } label: {
                            Text("Report")
                        }
                    }
                    .sheet(isPresented: $showReportMessageSheet) {
                        Text("Reporting message....")
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
                Task { @MainActor in
                    let status = await chatViewModel.createTideMessage(
                        tideId: singleTideViewModel.tide?.id ?? "",
                        text: messageContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        sender: userViewModel.user?.username ?? "",
                        userId: userViewModel.user?.id ?? ""
                    )
                    
                    switch status { // TODO: Provide feedback to user if message isn't created.
                    case .emptyMessage:
                        print("Cannot send message without content.")
                    case .failedToCreate:
                        print("Failed to send message :(")
                    case .invalidData:
                        print("Something went wrong while creating the message.")
                    case .sent:
                        messageContent = ""
                    default:
                        print("Unknown error occurred.")
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
    TidePageView(path: .constant([]), tideId: "123")
}
