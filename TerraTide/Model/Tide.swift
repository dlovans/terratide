//
//  Tide.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-03.
//

import FirebaseFirestore

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
}
