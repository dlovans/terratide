//
//  ChatView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-09.
//

import SwiftUI

struct ChatView: View {
    let chatId: String = "123"
    @FocusState private var chatFieldIsFocused: Bool
    
    let mockMessages: [Message] = [
        Message(id: "1", text: "Hey, how's it going?", sender: "Alice", timestamp: Date().addingTimeInterval(-3600)),
        Message(id: "10", text: "Hey, how's it going?", sender: "Alice", timestamp: Date().addingTimeInterval(-3600)),
        
        Message(id: "2", text: "Pretty good! Just working on my app.", sender: "You", timestamp: Date().addingTimeInterval(-3000)),
        Message(id: "3", text: "Nice! What are you building?", sender: "Alice", timestamp: Date().addingTimeInterval(-2400)),
        Message(id: "4", text: "A geospatial chat app.", sender: "You", timestamp: Date().addingTimeInterval(-1800)),
        Message(id: "5", text: "That sounds cool! How does it work?", sender: "Alice", timestamp: Date().addingTimeInterval(-1200)),
        Message(id: "6", text: "You can create and join activities based on location.", sender: "You", timestamp: Date().addingTimeInterval(-600)),
        Message(id: "7", text: "Interesting! Does it show people nearby?", sender: "Alice", timestamp: Date())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                Text("Geo Chat")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                ScrollViewReader { reader in
                    ScrollView {
                        LazyVStack {
                            ForEach(mockMessages) { message in
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
                                        reader.scrollTo(mockMessages.last!.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 7)
                    .defaultScrollAnchor(.bottom)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
                
                ChatFieldView(chatFieldIsFocused: $chatFieldIsFocused)
            }
        }
        .padding()
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
    ChatView()
}
