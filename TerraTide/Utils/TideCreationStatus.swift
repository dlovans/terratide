//
//  TideCreationStatus.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-18.
//

import Foundation

enum TideCreationStatus {
    case created(tideId: String), failed, invalidData, missingCredentials, missingTideId
}
