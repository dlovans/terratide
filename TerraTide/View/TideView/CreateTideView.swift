//
//  CreateTideView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-04.
//

import SwiftUI

struct CreateTideView: View {
    @EnvironmentObject private var tideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @Binding var path: [Route]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var maxParticipants: Int = 3
    
    @FocusState private var titleIsFocused: Bool
    @State private var offsetTitle: CGFloat = 0
    
    @FocusState private var descIsFocused: Bool
    @State private var offsetDesc: CGFloat = 0
    
    @FocusState private var participantsIsFocused: Bool
    
    private var tideIsValid: Bool {
        !title.isEmpty && maxParticipants > 1 && maxParticipants <= 10000 && !description.isEmpty
    }
    
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
                    .frame(width: 50, height: 30, alignment: .leading)
                    
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
                            }
                        }
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                }
                
                Button {
                    Task { @MainActor in
                        if tideIsValid {
                            Task { @MainActor in
                                let result = await tideViewModel.createTide(
                                    byUserID: self.userViewModel.user?.id ?? "",
                                    byUsername: self.userViewModel.user?.username ?? "",
                                    tideTitle: self.title,
                                    tideDescription: self.description,
                                    tideGroupSize: self.maxParticipants
                                )
                                
                                // TODO: Display error message on response.
                                switch result {
                                case .created(let newTideID):
                                    withAnimation {
                                        path.removeAll { $0 == .general("createTide") }
                                        path.append(.tide(newTideID))
                                    }
                                case .missingCredentials:
                                    print("Missing user credentials!")
                                case .invalidData:
                                    print("Tide data is invalid. Couldn't create Tide")
                                case .missingTideId:
                                    print("Tide was created but no Tide ID was returned!")
                                case .failed:
                                    print("Something went wrong while creating the Tide!")
                                }
                            }
                        }
                    }

                } label: {
                    Text("Three is a company")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!tideIsValid ? .gray : .orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .animation(.easeInOut, value: tideIsValid)
                }
                .buttonStyle(RemoveHighlightButtonStyle())
                .disabled(!tideIsValid)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding()
    }
}

#Preview {
    CreateTideView(path: .constant([]))
}
