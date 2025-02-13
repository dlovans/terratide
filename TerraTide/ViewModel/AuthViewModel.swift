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
    @Published var currentUserId: String?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }

            if let user = user {
                self.isAuthenticated = true
                self.currentUserId = user.uid
            } else {
                self.isAuthenticated = false
                self.currentUserId = nil
            }
        }
    }
    
    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
