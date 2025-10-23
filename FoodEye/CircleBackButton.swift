//
//  CircleBackButton.swift
//  FoodEye
//
//  Created by Codex on 6/2/25.
//

import SwiftUI

struct CircleBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            if let action {
                action()
            } else {
                dismiss()
            }
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
        .accessibilityLabel("Back")
    }
}

