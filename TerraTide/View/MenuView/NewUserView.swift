//
//  NewUserView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-10.
//

import SwiftUI

struct NewUserView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var username: String = ""
    @State private var usernameFeedback: String = ""
    @State private var usernameIsValid: Bool = false
    @State private var birthDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2005
        dateComponents.month = 1
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents) ?? Date()
    }()
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let fifteenYearsAgo = calendar.date(byAdding: .year, value: -15, to: Date())!
        let distantPast = calendar.date(byAdding: .year, value: -50, to: Date())!
        return distantPast...fifteenYearsAgo
    }()
    
    var body: some View {
        VStack (spacing: 30) {
            VStack {
                Text("Create a username (cannot be changed):")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    TextField("", text: $username)
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                }
                Text(usernameFeedback)
                    .font(.footnote)
                    .foregroundStyle(usernameIsValid ? Color.green : Color.red)
                    .frame(maxWidth: .infinity, minHeight: 20, alignment: .topLeading)
                    .animation(.easeInOut, value: usernameFeedback)
                    .animation(.easeInOut, value: usernameIsValid)
            }
            .onChange(of: username) { oldValue, newValue in
                    if newValue.isEmpty {
                        usernameIsValid = false
                        usernameFeedback = "Username cannot be empty."
                    } else if newValue.contains(" ") {
                        usernameIsValid = false
                        usernameFeedback = "Username cannot contain spaces."
                    } else if newValue.count > 15 {
                        usernameIsValid = false
                        usernameFeedback = "Username cannot be longer than 15 characters."
                    } else {
                        Task { @MainActor in
                            let result = await userViewModel.checkUsernameAvailability(for: newValue)
                            switch result {
                            case .available:
                                usernameFeedback = "Username available."
                                usernameIsValid = true
                            case .unavailable:
                                usernameFeedback = "Username not available."
                                usernameIsValid = false
                            case .error:
                                usernameFeedback = "An error occurred while checking username availability."
                                usernameIsValid = false
                                
                            }
                        }
                        usernameFeedback = ""
                        usernameIsValid = true
                    }
//                }
            }
            
            VStack {
                Text("Date of birth (used to display relevant Tides):")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                DatePicker("", selection: $birthDate, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
            }
            
            Button {
                Task { @MainActor in
                    let status  = await userViewModel.updateNewUserData(username: username, dateOfBirth: birthDate)
                    switch status {
                    case .updateSuccess:
                        print("Successfully updated username and date of birth.")
                    case .unAuthenticatedUser:
                        usernameFeedback = "You must be logged in to create a username"
                        usernameIsValid = false
                    case .usernameAlreadyExists:
                        usernameFeedback = "Username was taken before you could create it"
                        usernameIsValid = false
                    case .updateFailed:
                        usernameFeedback = "An error occurred while updating your username"
                        usernameIsValid = false
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Create")
                }
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(!usernameIsValid ? .gray : .orange.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.easeInOut, value: usernameIsValid)
            }
            .buttonStyle(TapEffectButtonStyle())
            .disabled(!usernameIsValid)
        }
        .padding()
    }
}

#Preview {
    NewUserView()
}
