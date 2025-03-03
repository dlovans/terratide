//
//  Message.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-07.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let byUserId: String
    let sender: String
    let timestamp: Date
    let adult: Bool
}
