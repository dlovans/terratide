//
//  FeedbackView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-02.
//

import SwiftUI

struct FeedbackView: View {
    @Binding var showFeedbackSheet: Bool
    @State private var feedbackText: String = ""
    @State private var isSendingFeedback: Bool = false
    @State private var respondentEmail: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            VStack (spacing: 30) {
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
                        // create feedback
                    } label: {
                        Text("Send Feedback")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    
                    Button {
                        showFeedbackSheet = false
                    } label: {
                        Text("Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
        .onTapGesture {
            isFocused = false
        }
    }
}

#Preview {
    FeedbackView(showFeedbackSheet: .constant(true))
}
