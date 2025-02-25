//
//  UserRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-14.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserRepository {
    let db = Firestore.firestore()
    
    
    /// Creates a document in the users collection in Firestore.
    /// - Returns: A boolean to indicate if operation was successful (or if user already exists) or a failure.
    func createUser() async -> Bool {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let snapshot = try await db.collection("users").document(userId).getDocument()
                if !snapshot.exists {
                    try await db.collection("users").document(userId).setData([
                        "username": ""
                    ])
                }
                return true
            } catch {
                print("Failed to create user document in Firestore: \(error)")
                return false
            }
        } else {
            return false
        }
    }
    
    /// Attaches a listener to the user document in Firestore, using uid of currently authenticated user.
    /// - Parameter completion: A closure that runs when the listener has been attached and when the user document in Firestore updates. Expects an instance of User model or nil.
    func attachUserListener(completion: @escaping (User?) -> Void) -> ListenerRegistration? {
        guard let userData = Auth.auth().currentUser else { return nil }
        
        let userListener = db.collection("users").document(userData.uid)
            .addSnapshotListener { documentSnapshot, error in
                if let error {
                    print("An error occurred while listening for user updates: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Error fetching documents: \(error!)")
                    completion(nil)
                    return
                }
                guard let data = document.data() else {
                  print("User document data was empty.")
                    completion(nil)
                    return
                }
                
                let userObject = User(
                            id: document.documentID,
                            username: data["username"] as? String ?? "",
                            blockedUsers: data["blockedUsers"] as? [String: String] ?? [:],
                            blockedByUsers: data["blockedByUsers"] as? [String] ?? [],
                            dateOfBirth: data["dateOfBirth"] as? Date ?? Date(),
                            isBanned: data["isBanned"] as? Bool ?? false,
                            banReason: data["banReason"] as? String ?? "",
                            banLiftDate: data["banLiftDate"] as? Date ?? Date()
                
                )
                completion(userObject)
            }
        return userListener
    }
    
    /// Checks if a username is available.
    /// - Parameter username: User-provided username.
    /// - Returns: An enumeration representing availability of username or error of operation.
    func checkUsernameAvailability(username: String) async -> UsernameAvailability {
        do {
            let querySnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
                .getDocuments()
            
            return querySnapshot.documents.isEmpty ? .available : .unavailable
        } catch {
            return .error
        }
    }
    
    
    /// Updates new user's username and date of birth.
    /// - Parameters:
    ///   - username: User-provided username.
    ///   - dateOfBirth: User-provided date of birth.
    /// - Returns: A value representing the status of this operation.
    func updateNewUserData(username: String, dateOfBirth: Date) async -> UpdateNewUserStatus {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let querySnapshot = try await db.collection("users").whereField("username", isEqualTo: username).limit(to: 1).getDocuments()
                if !querySnapshot.documents.isEmpty {
                    return .usernameAlreadyExists
                }
                
                try await db.collection("users").document(userId).updateData([
                    "username": username,
                    "dateOfBirth": dateOfBirth
                ])
                return .updateSuccess
            } catch {
                print("Failed to update new user data.")
                return .updateFailed
            }
        } else {
            return .unAuthenticatedUser
        }
    }
    
    /// Blocks a user. Messages and Tides by this user will not be seen.
    /// - Parameters:
    ///   - againstUserId: User being blocked.
    ///   - userId: User attempting to block.
    /// - Returns: Block status.
    func blockUser(blocking againstUserId: String, againstUsername: String, by userId: String) async -> BlockStatus {
        if againstUserId.isEmpty || userId.isEmpty || againstUsername.isEmpty {
            return .missingData
        }
        
        do {
            let userBlockingDocument = try await db.collection("users").document(userId).getDocument()
            if !userBlockingDocument.exists {
                print("User blocking document does not exist.")
                return .userBlockingNotFound
            }
            
            let blockingUserBlockedUsers = userBlockingDocument.data()?["blockedUsers"] as? [String:String] ?? [:]
            if blockingUserBlockedUsers.keys.contains(againstUserId) {
                print("User was already blocked.")
                return .alreadyBlocked
            }
            
            let userToBlockDocument = try await db.collection("users").document(againstUserId).getDocument()
            
            if !userToBlockDocument.exists {
                print("User to block does not exist.")
                return .userToBlockNotFound
            }
            
            try await db.collection( "users" ).document(userId).updateData([
                "blockedUsers.\(againstUserId)": againstUsername
            ])
            
            try await db.collection( "users" ).document(againstUserId).updateData([
                "blockedByUsers": FieldValue.arrayUnion( [userId] )
            ])
            
            return .blocked
        } catch {
            print("Failed to block user. Error: \(error)")
            return .failed
        }
    }
}
