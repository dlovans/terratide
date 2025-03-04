//
//  ReportView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-22.
//

import SwiftUI

struct ReportView: View {
    let reportType: ReportType
    var tideId: String? = nil
    var messageId: String? = nil
    var tideTitle: String? = nil
    var messageCreatorUsername: String? = nil
    var reportByUserId: String
    var reportAgainstUserId: String
    @Binding var showReportSheet: Bool
    
    @State private var reportCategory: ReportCategory = .datingSexual
    @State private var reportContent: String = ""
    @State private var overlayReportText = ""
    @State private var reportIsValid: Bool = false
    @State private var reportSent: Bool = false
    @State private var reportIsSending: Bool = false
    @State private var reportErrorMessage: String = ""
    @State private var displayErrorMessage: Bool = false
    @FocusState private var isFocused: Bool
    @EnvironmentObject private var reportViewModel: ReportViewModel
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text("Report \(reportType == .tide ? "Tide" : "Message")")
                if reportType != .tide {
                    Text("Created by: \(messageCreatorUsername ?? "Unknown")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                    .padding(.vertical, 5)
                
                HStack {
                    Text("Category:")
                    Spacer()
                    Picker("", selection: $reportCategory) {
                        ForEach(ReportCategory.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .tint(.orange)
                }
                
                Divider()
                    .padding(.vertical, 5)
                
                Text("Why are you reporting?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $reportContent)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                    .focused($isFocused)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.orange, lineWidth: 1)
                    }
                    .overlay {
                        Text(!reportIsValid ? "Report reason cannot be empty!" : "")
                            .allowsHitTesting(false)
                            .opacity(0.7)
                    }
                    .onChange(of: reportContent) { _, newValue in
                        if newValue.isEmpty {
                            reportIsValid = false
                        } else if !newValue.isEmpty && !reportIsValid {
                            reportIsValid = true
                        }
                        
                        if newValue.count > 700 {
                            reportContent = String(newValue.prefix(700))
                        }
                    }
                
                Divider()
                    .padding(.vertical, 5)
                
                HStack (spacing: 10) {
                    Button {
                        isFocused = false
                        showReportSheet = false
                    } label: {
                        Text(reportSent ? "Close" : "Cancel")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(reportIsSending ? .gray : .red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    .disabled(reportIsSending)
                    
                    Button {
                        Task {@MainActor in
                            isFocused = false
                            reportIsSending = true
                            
                            var status: ReportStatus
                            
                            if reportType == .geoMessage || reportType == .tideMessage {
                                status = await reportViewModel.report(reportType: reportType, messageId: messageId, reportByUserId: reportByUserId, reportAgainstUserId: reportAgainstUserId, reportContent: reportContent, reportCategory: reportCategory)
                            } else {
                                status = await reportViewModel.report(reportType: reportType, tideId: tideId, reportByUserId: reportByUserId, reportAgainstUserId: reportAgainstUserId, reportContent: reportContent, reportCategory: reportCategory)
                            }
                                                        
                            switch status {
                            case .success:
                                reportSent = true
                            case .missingData:
                                reportErrorMessage = "Failed to create report. Some critical information were missing :( Try again soon."
                            case .failure:
                                reportErrorMessage = "Failed to create report. Please try again later."
                            }
                            
                            if !reportSent {
                                displayErrorMessage = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    displayErrorMessage = false
                                }
                            }
                            
                            reportIsSending = false
                        }
                    } label: {
                        Text(!reportSent ? "Report" : reportIsSending ? "Sending..." : "Sent!")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(!reportIsValid || reportIsSending || reportSent ? .gray : .green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(TapEffectButtonStyle())
                    .disabled(!reportIsValid || reportIsSending || reportSent)
                }
                    
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .onTapGesture {
                isFocused = false
            }
            
            VStack {
                Text(reportErrorMessage)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.2))
            .scaleEffect(displayErrorMessage ? 1 : 0)
            .animation(.snappy, value: displayErrorMessage)
        }
    }
}

#Preview {
    ReportView(reportType: .geoMessage, reportByUserId: "asd", reportAgainstUserId: "adqw", showReportSheet: .constant(true))
}
