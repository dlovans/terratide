//
//  ReportRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-21.
//

import Foundation
import FirebaseFirestore

class ReportRepository {
    let db = Firestore.firestore()
    
    /// Creates a report document in specified collection (raw value of report type).
    /// - Note: Handles 3 types of reports based on `ReportType`: `Tide`, `Tide message`, and `Geo message`. Report type depends on the value of `reportType`.
    /// - Parameters:
    ///   - reportType: Type of report to create in database. Each type corresponds to a different collection.
    ///   - tideId: ID of the Tide where report is created. Relevant for `Tide` and `Tide message` reports.
    ///   - messageId: ID of the message being reported. Relevant for `Tide message` and `Geo message` reports.
    ///   - reportByUserId: User ID of the user creating report.
    ///   - reportAgainstUserId: User ID of the user being reported.
    ///   - reportContent: Description of the report provided by the reporting user.
    ///   - reportCategory: Report category.
    /// - Returns: Report document creation status.
    func report(
        reportType: ReportType,
        tideId: String?,
        messageId: String?,
        reportByUserId: String,
        reportAgainstUserId: String,
        reportContent: String,
        reportCategory: ReportCategory
    ) async -> ReportStatus {
        if reportByUserId.isEmpty || reportAgainstUserId.isEmpty || reportContent.isEmpty {
            print("Missing required report fields.")
            return .missingData
        }
        
        var reportData: [String: Any] = [
            "reportByUserId": reportByUserId,
            "reportAgainstUserId": reportAgainstUserId,
            "reportContent": reportContent,
            "reportCategory": reportCategory.rawValue,
            "reportDate": FieldValue.serverTimestamp(),
            "isHandled": false
        ]
        
        switch reportType {
            case .tide:
                guard let tideId = tideId else {
                    print("Missing tideId for tide report.")
                    return .missingData
                }
                reportData["tideId"] = tideId
            case .tideMessage:
                guard let tideId = tideId, let messageId = messageId else {
                    print("Missing tideId or messageId for tide message report.")
                    return .missingData
                }
                reportData["tideId"] = tideId
                reportData["messageId"] = messageId
            case .geoMessage:
                guard let messageId = messageId else {
                    print("Missing messageId for geo message report.")
                    return .missingData
                }
                reportData["messageId"] = messageId
            }
        
        do {
            try await db.collection(reportType.rawValue).addDocument(data: reportData)
            
            return .success
        } catch {
            print("Failed to create a report of type \(reportType.rawValue).")
            return .failure
        }
    }
}
