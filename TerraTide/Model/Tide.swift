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
    let tideGroupSize: Int
    let memberIds: [String: String]
}
