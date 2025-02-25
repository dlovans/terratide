//
//  LocationPermissionView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import SwiftUI

struct LocationPermissionView: View {
    @EnvironmentObject var locationService: LocationService
    var body: some View {
        ZStack {
            VStack {
                Text("To use this app, enable location access in your settings.")
                Button {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Enable Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                .buttonStyle(TapEffectButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    LocationPermissionView()
}
