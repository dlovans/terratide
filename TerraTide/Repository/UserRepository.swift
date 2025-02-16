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
                
                let userObject = User(id: data["id"] as? String ?? "",
                            username: data["username"] as? String ?? "",
                            blockedUserIds: data["blockedUserIds"] as? [String] ?? [],
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
}
