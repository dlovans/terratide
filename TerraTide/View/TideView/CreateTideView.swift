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
    @EnvironmentObject private var locationService: LocationService
    
    @Binding var path: [Route]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var maxParticipants: Int = 3
    
    @FocusState private var titleIsFocused: Bool
    @State private var offsetTitle: CGFloat = 0
    
    @FocusState private var descIsFocused: Bool
    @State private var offsetDesc: CGFloat = 0
    
    @FocusState private var participantsIsFocused: Bool
    
    @State private var errorMessage: String = ""
    @State private var displayErrorMessage: Bool = false
    @State private var messageWorkItem: DispatchWorkItem?
    @State private var isCreatingTide: Bool = false
    
    private var tideIsValid: Bool {
        !title.isEmpty && maxParticipants > 1 && maxParticipants <= 10000 && !description.isEmpty && locationService.boundingBox != nil
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
                
                TextField("", text: $title, axis: .vertical)
                    .lineLimit(1)
                    .padding()
                    .focused($titleIsFocused)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 1)
                    }
                    .overlay {
                        Text("Tide Title")
                            .opacity(titleIsFocused || !title.isEmpty ? 0.8 : 0.5)
                            .padding(.horizontal, 3)
                            .background(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .padding(.leading, 12)
                            .offset(y: titleIsFocused || !title.isEmpty ? -28 : 0)
                            .animation(.easeInOut(duration: 0.2), value: titleIsFocused)
                            .allowsHitTesting(false)
                    }
                    .onChange(of: title) { _, newValue in
                        if newValue.count > 30 {
                            title = String(newValue.prefix(30))
                        }
                    }
                
                TextField("", text: $description, axis: .vertical)
                    .lineLimit(6, reservesSpace: true)
                    .padding()
                    .focused($descIsFocused)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 1)
                    }
                    .overlay {
                        Text("Description")
                            .opacity(descIsFocused || !description.isEmpty ? 0.8 : 0.5)
                            .padding(.horizontal, 3)
                            .background(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading, 12)
                            .padding(.top, 10)
                            .offset(y: descIsFocused || !description.isEmpty ? -20 : 0)
                            .animation(.easeInOut(duration: 0.2), value: descIsFocused)
                            .allowsHitTesting(false)
                    }
                    .onChange(of: description) { _, newValue in
                        if newValue.count > 300 {
                            description = String(newValue.prefix(300))
                        }
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
                        let result: TideCreationStatus
                        isCreatingTide = true
                        titleIsFocused = false; participantsIsFocused = false; descIsFocused = false
                        messageWorkItem?.cancel()
                        displayErrorMessage = false
                            if let user = userViewModel.user {
                               result = await tideViewModel.createTide(
                                    byUserID: self.userViewModel.user?.id ?? "",
                                    byUsername: self.userViewModel.user?.username ?? "",
                                    tideTitle: self.title,
                                    tideDescription: self.description,
                                    maxParticipants: self.maxParticipants,
                                    boundingBox: locationService.boundingBox!,
                                    adult: user.adult
                                )
                            } else {
                                result = .missingCredentials
                            }
                        
                        var isError = true
                        switch result {
                        case .created(let newTideID):
                            isError = false
                            withAnimation {
                                path.removeAll { $0 == .general("createTide") }
                                path.append(.tide(newTideID))
                            }
                        case .missingCredentials:
                            errorMessage = "Missing user credentials!"
                        case .invalidData:
                            errorMessage = "Tide data is invalid. Couldn't create Tide."
                        case .missingTideId:
                            errorMessage = "Tide was created but no Tide was returned!"
                        case .failed:
                            errorMessage = "Something went wrong while creating the Tide!"
                        }
                        
                        if isError {
                            displayErrorMessage = true
                            
                            messageWorkItem = DispatchWorkItem {
                                displayErrorMessage = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: messageWorkItem!)
                            isCreatingTide = false
                        }
                    }
                    
                } label: {
                    Text("Create")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!tideIsValid ? LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.indigo, .orange], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .animation(.easeInOut, value: tideIsValid)
                }
                .buttonStyle(TapEffectButtonStyle())
                .disabled(!tideIsValid || isCreatingTide)
                
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding()
    }
}

#Preview {
    CreateTideView(path: .constant([]))
}
