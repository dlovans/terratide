//
//  ReportCategory.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-22.
//

import Foundation

enum ReportCategory: String, CaseIterable {
    case inappropriateContent = "Inappropriate Content"
    case spam = "Spam"
    case misinformation = "Misinformation"
    case offensiveLanguage = "Offensive Language"
    case hateSpeech = "Hate Speech"
    case impersonation = "Impersonation"
    case harassment = "Harassment"
    case threats = "Threats"
    case disrespectfulBehavior = "Disrespectful Behavior"
    case scammingPhishing = "Scamming/Phishing"
    case suspiciousActivity = "Suspicious Activity"
    case violationToS = "Violation of Terms of Service"
    case illegalActivity = "Illegal Activity"
    case privacyViolations = "Privacy Violations"
}
