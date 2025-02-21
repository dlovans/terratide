//
//  User.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-13.
//

import Foundation

struct User {
    let id: String
    let username: String
    let blockedUsers: [String: String]
    let dateOfBirth: Date?
    let isBanned: Bool
    let banReason: String
    let banLiftDate: Date?
}
