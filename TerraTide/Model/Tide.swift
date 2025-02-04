//
//  Tide.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-03.
//


struct Tide: Identifiable, Hashable, Equatable {
    let id: Int
    let title: String
    let description: String
    let creator: String
    let participants: Int
    let maxParticipants: Int
}
