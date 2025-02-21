//
//  UserViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-13.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userDataLoaded: Bool = false
    @Published var initialLoadComplete: Bool = false
    
    private var userListener: ListenerRegistration? = nil
    
    private var userRepository = UserRepository()
    var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        Task { @MainActor in
            handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                guard let self else { return }
                
                self.userListener?.remove()
                self.userListener = nil

                if let _ = user {
                    self.userListener = userRepository.attachUserListener { [weak self] user in
                        guard let self else { return }
                        if let user {
                            self.user = user
                            self.userDataLoaded = true
                        }
                    }
                } else {
                    self.user = nil
                    self.userDataLoaded = false
                }
            }
            
            self.initialLoadComplete = true
        }
    }

    
    
    /// Creates a user document in users collection.
    /// - Returns: Whether a user document was successfully created (or if it exists, will return true) or not.
    func createUser() async -> Bool {
        return await userRepository.createUser()
    }
    
    /// Attaches a listener, listening to a user document of currently authenticated user. Updates User instance.
    func attachUserListener() {
        let newUserListener = userRepository.attachUserListener() { [weak self] user in
            if let user {
                self?.user = user
            }
        }
        if !userDataLoaded {
            userDataLoaded = true
        }
        self.userListener = newUserListener
    }
    
    /// Checks if a username is available.
    /// - Parameter username: User-provided username.
    /// - Returns: An enumeration representing availability of username or error of operation.
    func checkUsernameAvailability(for username: String) async -> UsernameAvailability {
        return await userRepository.checkUsernameAvailability(username: username)
    }
    
    /// Updates new user's username and date of birth.
    /// - Parameters:
    ///   - username: User-provided username.
    ///   - dateOfBirth: User-provided date of birth.
    /// - Returns: A value representing the status of this operation.
    func updateNewUserData(username: String, dateOfBirth: Date) async -> UpdateNewUserStatus {
        return await userRepository.updateNewUserData(username: username, dateOfBirth: dateOfBirth)
    }
}
