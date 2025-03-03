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
    let blockedByUsers: [String]
    let adult: Bool
    let isBanned: Bool
    let banReason: String
    let banLiftDate: Date?
}
