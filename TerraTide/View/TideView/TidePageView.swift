//
//  TidePageView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct TidePageView: View {
    @EnvironmentObject private var tideViewModel: TideViewModel
    @Binding var path: [Route]
    @State private var displayChat: Bool = true
    
    let tideId: String
    
    var body: some View {
        ZStack {
            if !tideViewModel.tideHasLoaded && !tideViewModel.tideChatHasLoaded {
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
                        Text(tideViewModel.tide?.title ?? "")
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
                            TideChatView()
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
                if !tideViewModel.tideHasLoaded {
                    tideViewModel.attachTideListener(tideId: tideId)
                }
                
//                if !tideViewMode.tideChatHasLoaded {
//                    tideViewModel.attachTideChatListener(tideId: tideId)
//                }
            }
        }
    }
}

struct TideDetailsView: View {
    @EnvironmentObject private var tideViewModel: TideViewModel
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
                    Text("\(tideViewModel.tide?.memberIds.count ?? 1)/\(tideViewModel.tide?.tideGroupSize ?? 10)")
                }
                
                Text(tideViewModel.tide?.description ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack {
                    Text("Members:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 3), spacing: 10) {
                
                            TideMemberView(userId: tideViewModel.tide?.creatorId ?? "", username: tideViewModel.tide?.creatorUsername ?? "")
                            if let memberIds = tideViewModel.tide?.memberIds {
                                ForEach(memberIds.keys.sorted().filter { $0 != tideViewModel.tide?.creatorId ?? ""}, id: \.self) { memberId in
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
    let chatId: String = "123"
    @FocusState private var chatFieldIsFocused: Bool
    
    let mockMessages: [Message] = [
        Message(id: "1", text: "Hey, how's it going?", byUserId: "wdasd", sender: "Alice", timestamp: Date().addingTimeInterval(-3600)),
        Message(id: "10", text: "Hey, how's it going?", byUserId: "wdasd", sender: "Alice", timestamp: Date().addingTimeInterval(-3600)),
        
        Message(id: "2", text: "Pretty good! Just working on my app.", byUserId: "wdasd", sender: "You", timestamp: Date().addingTimeInterval(-3000)),
        Message(id: "3", text: "Nice! What are you building?", byUserId: "wdasd", sender: "Alice", timestamp: Date().addingTimeInterval(-2400)),
        Message(id: "4", text: "A geospatial chat app.", byUserId: "wdasd", sender: "You", timestamp: Date().addingTimeInterval(-1800)),
        Message(id: "5", text: "That sounds cool! How does it work?", byUserId: "wdasd", sender: "Alice", timestamp: Date().addingTimeInterval(-1200)),
        Message(id: "6", text: "You can create and join activities based on location.", byUserId: "wdasd", sender: "You", timestamp: Date().addingTimeInterval(-600)),
        Message(id: "7", text: "Interesting! Does it show people nearby?", byUserId: "wdasd", sender: "Alice", timestamp: Date())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { reader in
                    ScrollView {
                        LazyVStack {
                            ForEach(mockMessages) { message in
                                TideChatMessageView(
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
                                        reader.scrollTo(mockMessages.last!.id)
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
    let createdBy: String
    let messageContent: String
    let timeStamp: Date
    
    let mockSelfUser = "You"
    
    @State private var showReportMessageSheet: Bool = false
    
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
                            showReportMessageSheet = true
                        } label: {
                            Text("Report")
                        }
                    }
                    .sheet(isPresented: $showReportMessageSheet) {
                        Text("Reporting message....")
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

struct TideChatFieldView: View {
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
                // Send message
                messageContent = ""
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
