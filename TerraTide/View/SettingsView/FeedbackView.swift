//
//  FeedbackView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-02.
//

import SwiftUI

struct FeedbackView: View {
    @Binding var showFeedbackSheet: Bool
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var feedbackText: String = ""
    @State private var isSendingFeedback: Bool = false
    @State private var respondentEmail: String = ""
    @State private var errorMessage: String = ""
    @State private var displayErrorMessage: Bool = false
    @State private var feedbackSent: Bool = false
    @State private var feedbackButtonText: String = "Send Feedback"
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            VStack (spacing: 15) {
                HStack {
                    Button {
                        isFocused = false
                    } label: {
                        Text("Done")
                    }
                    .hidden()
                    
                    Spacer()
                    
                    Text("Feedback")
                        .font(.title)
                    Spacer()
                    Button {
                        isFocused = false
                    } label: {
                        Text("Done")
                    }
                    .opacity(isFocused ? 1 : 0)
                }
                
                VStack {
                    Text("Email for response:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Leave empty if you don't want a response!", text: $respondentEmail)
                        .focused($isFocused)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.orange, lineWidth: 1)
                        }
                }
                
                VStack {
                    Text("Feedback:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextEditor(text: $feedbackText)
                        .focused($isFocused)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.orange, lineWidth: 1)
                        }
                }
                
                VStack {
                    Button {
                        Task { @MainActor in
                            isFocused = false
                            isSendingFeedback = true
                            feedbackButtonText = "Sending..."
                            
                            let status = await userViewModel.createFeedback(respondentEmail: respondentEmail, feedbackText: feedbackText, byUserId: userViewModel.user?.id ?? "")
                            
                            if status {
                                feedbackSent = true
                                feedbackButtonText = "Feedback Sent!"
                            } else {
                                feedbackButtonText = "Try again"
                                errorMessage = "Failed to send feedback. Send me an email instead at dlovan@terratide.app, or try again later!"
                                displayErrorMessage = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    displayErrorMessage = false
                                }
                            }
                            
                            isSendingFeedback = false
                        }
                    } label: {
                        Text(feedbackButtonText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(isSendingFeedback || feedbackText.isEmpty || feedbackSent ? .gray : .orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    .disabled(isSendingFeedback || feedbackText.isEmpty || feedbackSent)
                    
                    Button {
                        showFeedbackSheet = false
                    } label: {
                        Text(feedbackSent ? "Close" : "Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(isSendingFeedback ? .gray : .red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    .disabled(isSendingFeedback)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            Text(errorMessage)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.black)
                .foregroundStyle(.white)
                .font(.caption)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: displayErrorMessage ? 0 : -500)
                .opacity(displayErrorMessage ? 1 : 0)
                .animation(.easeInOut, value: displayErrorMessage)
        }
        .padding()
        .onTapGesture {
            isFocused = false
        }
    }
}

#Preview {
    FeedbackView(showFeedbackSheet: .constant(true))
}
