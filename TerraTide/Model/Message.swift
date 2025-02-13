//
//  Message.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-07.
//

import Foundation

struct Message: Identifiable {
    let id: String
    let text: String
    let sender: String
    let timestamp: Date
}
