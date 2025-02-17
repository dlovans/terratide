//
//  AuthViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-13.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var initialLoadComplete = false
    
    let authRepository = AuthRepository()
    var handle: AuthStateDidChangeListenerHandle?
    
    /// Registers listener for authentication state.
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let _ = user {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
            
            initialLoadComplete = true
        }
    }
    
    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    /// Registers user with email and password, with Firebase Auth
    /// - Parameters:
    ///   - email: User-provided email.
    ///   - password: User-provided password.
    ///   - completion: A closure that is called when Firebase authentication operation completes.
    ///     It provides a `Result` with either a successful `AuthDataResult` or `Error` if authentication operation fails.
    func registerWithEmailAndPassword(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        authRepository.registerWithEmailAndPassword(email: email, password: password) { result in
            switch result {
            case .success(let authDataResult):
                completion(.success(authDataResult))
            case .failure(let error):
                print("Failed to register user with email and password!")
                completion(.failure(error))
            }
            
        }
    }
    
    /// Sign in users with email and password.
    /// - Parameters:
    ///   - email: User-provided email
    ///   - password: User-provided password
    ///   - completion: A closure that is called after a sign in attempt is completed.
    func signInWithEmailAndPassword(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        authRepository.signInWithEmailAndPassword(email: email, password: password) { result in
            switch result {
            case .success(let authDataResult):
                completion(.success(authDataResult))
            case .failure(let error):
                if let error = error as NSError? {
                    if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                        completion(.failure(authErrorCode))
                    } else {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Signs out user from Firebase.
    /// - Returns: `AuthStatus` - `.logoutFailure` for sign out failure and `.logoutSuccess` for sign out success.
    func signOut() -> AuthStatus {
        return authRepository.signOut()
    }
}
