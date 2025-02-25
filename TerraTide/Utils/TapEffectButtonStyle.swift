//
//  TapEffectButtonStyle.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-24.
//

import SwiftUI

struct TapEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
