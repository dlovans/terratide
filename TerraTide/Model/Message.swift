//
//  Message.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-07.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let byUserId: String
    let sender: String
    let timestamp: Date
}
