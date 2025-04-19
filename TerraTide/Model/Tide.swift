//
//  Tide.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-03.
//

import FirebaseFirestore
import Foundation

struct Tide: Identifiable, Hashable, Equatable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let creatorId: String
    let creatorUsername: String
    let participantCount: Int
    let maxParticipants: Int
    let members: [String: String]
    let memberIds: [String]
    let adult: Bool
    let category: String
    
    // Computed property to get the TideCategory enum value
    var tideCategory: TideCategory {
        return TideCategory(rawValue: category) ?? .other
    }
}
