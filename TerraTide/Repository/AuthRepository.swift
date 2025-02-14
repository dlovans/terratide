//
//  AuthRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-13.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthRepository {
    /// Register user with email and password using Firebase Auth.
    /// - Parameters:
    ///   - email: User-provided email.
    ///   - password: User-provided password.
    ///   - completion: A closure that is called when the registration attempt is completed.
    ///     It provides a `Result` with either a successful `AuthDataResult` or an `Error` if registration fails.
    func registerWithEmailAndPassword(
        email: String,
        password: String,
        completion: @escaping (Result<AuthDataResult, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = authResult else {
                let authError = NSError(domain: "AuthError", code: -1, userInfo: nil)
                completion(.failure(authError))
                return
            }
            
            completion(.success(authResult))
        }
    }
    
    /// Signs out user from Firebase.
    /// - Returns: Sign out status. Used to display feedback to user if sign out fails.
    func signOut() -> AuthStatus {
        do {
            try Auth.auth().signOut()
            return .logoutSuccess
        } catch {
            print("Failed to sign out user!")
            return .logoutFailure
        }
    }
}
