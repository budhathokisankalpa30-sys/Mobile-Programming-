//
//  Theme.swift
//  EquityFlow
//
//  Design tokens and reusable styling for the EquityFlow fintech app.
//

import SwiftUI

enum EquityTheme {
    // MARK: - Colors
    static let primary = Color(hex: "00C896")
    static let primaryDark = Color(hex: "009E74")
    static let secondary = Color(hex: "4D7CFE")
    static let accent = Color(hex: "F5B700")
    static let background = Color(hex: "0F172A")
    static let surface = Color(hex: "1E293B")
    static let card = Color(hex: "111827")
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "FACC15")
    static let danger = Color(hex: "EF4444")
    static let textPrimary = Color(hex: "FFFFFF")
    static let textSecondary = Color(hex: "CBD5E1")
    static let border = Color(hex: "334155")
    static let chartPositive = Color(hex: "00C896")
    static let chartNegative = Color(hex: "EF4444")

    // MARK: - Gradients
    static let walletGradient = LinearGradient(
        colors: [Color(hex: "00C896"), Color(hex: "009E74")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0F172A"), Color(hex: "0B1120")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "00C896"), Color(hex: "4D7CFE")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Typography
    static func titleLarge(_ content: some View) -> some View {
        content
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(textPrimary)
    }

    static func titleMedium(_ content: some View) -> some View {
        content
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(textPrimary)
    }

    static func headline(_ content: some View) -> some View {
        content
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(textPrimary)
    }

    static func body(_ content: some View) -> some View {
        content
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundStyle(textSecondary)
    }

    static func caption(_ content: some View) -> some View {
        content
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(textSecondary)
    }

    static func valueLarge(_ content: some View) -> some View {
        content
            .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
            .foregroundStyle(textPrimary)
    }

    // MARK: - Card Style
    struct CardStyle: ViewModifier {
        let padding: CGFloat
        let cornerRadius: CGFloat

        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(card)
                .clipShape(.rect(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(border, lineWidth: 1)
                )
        }
    }

    static func card(padding: CGFloat = 18, cornerRadius: CGFloat = 18) -> CardStyle {
        CardStyle(padding: padding, cornerRadius: cornerRadius)
    }

    // MARK: - Button Styles
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(primary)
                .clipShape(.rect(cornerRadius: 14))
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(surface)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(border, lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - Color HEX Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
