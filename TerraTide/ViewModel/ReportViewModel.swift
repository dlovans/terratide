//
//  ReportViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-22.
//

import Foundation

class ReportViewModel: ObservableObject {
    let reportRepository = ReportRepository()
    
    /// Calls method in ReportRepository to create a `Tide` or `Message` report.
    /// - Parameters:
    ///   - reportType: Type of report. Acceptable values are `.tide`, `.geoMessage` and `.tideMessage`.
    ///   - tideId: ID of Tide being reported. Set to nil if report type is `.geoMessage` or `.tideMessage`.
    ///   - messageId: ID of message being reported. Set to nil if report type is `.tide`.
    ///   - reportByUserId: User ID of the user creating report.
    ///   - reportAgainstUserId: User ID of the user being reported (or creator of Tide).
    ///   - reportContent: Report reason provided by the reporting user.
    ///   - reportCategory: Report category reason.
    /// - Returns: Report creation status.
    func report(
        reportType: ReportType,
        tideId: String? = nil,
        messageId: String? = nil,
        reportByUserId: String,
        reportAgainstUserId: String,
        reportContent: String,
        reportCategory: ReportCategory
    ) async -> ReportStatus {
        return await reportRepository.report(
            reportType: reportType,
            tideId: tideId,
            messageId: messageId,
            reportByUserId: reportByUserId,
            reportAgainstUserId: reportAgainstUserId,
            reportContent: reportContent,
            reportCategory: reportCategory
        )
    }
}
