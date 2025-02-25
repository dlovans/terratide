//
//  BanHammerView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-10.
//

import SwiftUI

struct BanHammerView: View {
    private var userId: String = "12345677777777777"
    private var email: String = "dlovan@terratide.app"
    @State private var displayUserIdToast = false
    @State private var displayEmailToast = false
    @State private var userIdWorkItem: DispatchWorkItem?
    @State private var emailWorkItem: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Spacer()
                Spacer()
                Image(systemName: "hammer.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.indigo)
                Text("You've been banned!")
                Text("Ban reason: You defamed Harambe.")
                HStack {
                    Text("Ban lifts in:")
                    Text(Date.now.addingTimeInterval(2500000), style: .relative)
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                Spacer()
                VStack (spacing: 10) {
                    Text("Do you think this was a mistake?")
                    Text("Copy your user ID. Send me an email with your user ID and explain why you think this was a mistake.")
                    Button {
                        UIPasteboard.general.string = userId
                        emailWorkItem?.cancel()
                        withAnimation {
                            displayEmailToast = false
                            displayUserIdToast = true
                        }
                        
                        userIdWorkItem?.cancel()
                        
                        let workItem = DispatchWorkItem {
                            withAnimation {
                                displayUserIdToast = false
                            }
                        }
                        
                        userIdWorkItem = workItem
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
                    } label: {
                        HStack {
                            Text(userId)
                            Image(systemName: "document.on.document")
                        }
                        .foregroundStyle(.green.opacity(0.8))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    
                    Button {
                        UIPasteboard.general.string = email
                        userIdWorkItem?.cancel()
                        withAnimation {
                            displayUserIdToast = false
                            displayEmailToast = true
                        }
                        
                        emailWorkItem?.cancel()
                        
                        let workItem = DispatchWorkItem {
                            withAnimation {
                                displayEmailToast = false
                            }
                        }
                        
                        emailWorkItem = workItem
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
                    } label: {
                        HStack {
                            Text(email)
                            Image(systemName: "document.on.document")
                        }
                        .foregroundStyle(.green.opacity(0.8))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                }
            }
            VStack {
                Text("User ID copied to clipboard!")
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(displayUserIdToast ? 1 : 0)
                    .offset(x: displayUserIdToast ? 0 : -500)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top)
            VStack {
                Text("Email copied to clipboard!")
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(displayEmailToast ? 1 : 0)
                    .offset(x: displayEmailToast ? 0 : -500)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top)
        }
        .padding()
    }
}


#Preview {
    BanHammerView()
}
