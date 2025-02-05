//
//  CreateTideView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-04.
//

import SwiftUI

struct CreateTideView: View {
    @Binding var path: [Route]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var maxParticipants: Int = 3
    @State private var currentParticipants: Int = 1
    
    @FocusState private var titleIsFocused: Bool
    @State private var offsetTitle: CGFloat = 0
    
    @FocusState private var descIsFocused: Bool
    @State private var offsetDesc: CGFloat = 0
    
    @FocusState private var participantsIsFocused: Bool
    
    @State private var approvalRequired: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .onTapGesture {
                    titleIsFocused = false
                    descIsFocused = false
                    participantsIsFocused = false
                }
            
            VStack (spacing: 20) {
                HStack {
                    Button {
                        path.removeAll { $0 == .general("createTide") }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 50, alignment: .leading)
                    Spacer()
                    Text("Create a Tide!")
                        .font(.title2)
                    Spacer()
                    ZStack {
                        Button("", systemImage: "arrow.backward") {
                            print("Hidden, don't touch")
                        }
                        .hidden()
                        if titleIsFocused || descIsFocused || participantsIsFocused {
                            Button {
                                if titleIsFocused {
                                    titleIsFocused = false
                                }
                                if descIsFocused {
                                    descIsFocused = false
                                }
                                if participantsIsFocused {
                                    participantsIsFocused = false
                                }
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .frame(width: 50, alignment: .trailing)
                    .padding(0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    TextField("", text: $title)
                        .padding()
                        .focused($titleIsFocused)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        }
                    HStack {
                        Text("Tide Title")
                            .opacity(titleIsFocused || !title.isEmpty ? 0.8 : 0.5)
                            .padding(.horizontal, 3)
                            .background(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                    .offset(y: titleIsFocused || !title.isEmpty ? -28 : 0)
                    .animation(.easeInOut(duration: 0.2), value: titleIsFocused)
                    .allowsHitTesting(false)
                }
                .padding(.top)
                
                ZStack {
                    TextField("", text: $description)
                        .padding()
                        .focused($descIsFocused)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        }
                    HStack {
                        Text("Description")
                            .opacity(descIsFocused || !description.isEmpty ? 0.8 : 0.5)
                            .padding(.horizontal, 3)
                            .background(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                    .offset(y: descIsFocused || !description.isEmpty ? -28 : 0)
                    .animation(.easeInOut(duration: 0.2), value: descIsFocused)
                    .allowsHitTesting(false)
                }
                
                HStack {
                    Text("How many are you now?")
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                    TextField("", value: $currentParticipants, format: .number)
                        .focused($participantsIsFocused)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        }
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                        .onChange(of: currentParticipants) { oldValue, newValue in
                            if newValue > 9999 {
                                currentParticipants = 9999
                            } else if newValue < 1 {
                                currentParticipants = 1
                            }
                        }
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                }
                
                HStack {
                    Text("Max participants?")
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                    TextField("", value: $maxParticipants, format: .number)
                        .focused($participantsIsFocused)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        }
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                        .onChange(of: maxParticipants) { oldValue, newValue in
                            if newValue > 10000 {
                                maxParticipants = 10000
                            } else if newValue <= currentParticipants {
                                maxParticipants = currentParticipants + 1
                            }
                        }
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                }
                
                Toggle("Approve who can join?", isOn: $approvalRequired)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 1)
                    }
                    .tint(.orange)
                
                Button {
                    // Create button. Creates tide, returns TideID, appending id path to Route
                } label: {
                    Text("Three is a company")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.orange)
                        .cornerRadius(10)
                }
                .buttonStyle(RemoveHighlightButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
        }
    }
}

#Preview {
    CreateTideView(path: .constant([]))
}
