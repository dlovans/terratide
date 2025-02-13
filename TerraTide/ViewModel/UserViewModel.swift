//
//  UserViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-13.
//

import Foundation
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var user: User? = nil
}
