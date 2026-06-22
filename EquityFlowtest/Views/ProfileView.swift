//
//  ProfileView.swift
//  EquityFlow
//

import SwiftUI

struct ProfileView: View {
    @Environment(PortfolioService.self) private var service
    @Environment(FirebaseAuthService.self) private var authService
    @Environment(FirestoreService.self) private var firestoreService
    @State private var appeared = false
    @State private var showSignOutConfirmation = false
    @State private var signOutError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)

                accountSummary
                    .opacity(appeared ? 1 : 0)

                settingsSection
                    .opacity(appeared ? 1 : 0)

                signOutButton
                    .opacity(appeared ? 1 : 0)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(EquityTheme.backgroundGradient)
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                firestoreService.stopListening()
                do { try authService.signOut() } catch {
                    signOutError = error.localizedDescription
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(EquityTheme.accentGradient)
                    .frame(width: 72, height: 72)
                Text(userInitials)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: EquityTheme.primary.opacity(0.2), radius: 12, y: 4)

            VStack(spacing: 4) {
                Text(authService.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
                Text("Premium Investor")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(EquityTheme.primary)
            }

            if !authService.email.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 12, weight: .medium))
                    Text(authService.email)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
                .foregroundStyle(EquityTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(EquityTheme.surface)
                .clipShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(EquityTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Account Summary
    private var accountSummary: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Account Summary")
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                AccountRow(icon: "chart.bar.fill", iconColor: EquityTheme.primary, title: "Portfolio Value", value: service.portfolio.formattedTotalValue)
                AccountRow(
                    icon: "arrow.up.right",
                    iconColor: EquityTheme.success,
                    title: "Total Gain/Loss",
                    value: "\(service.portfolio.totalReturn >= 0 ? "+" : "")\(String(format: "%.2f", service.portfolio.totalReturnPercent))%",
                    valueColor: service.portfolio.totalReturn >= 0 ? EquityTheme.success : EquityTheme.danger
                )
                AccountRow(
                    icon: "dollarsign.circle",
                    iconColor: EquityTheme.secondary,
                    title: "Total Invested",
                    value: service.portfolio.investments.reduce(0) { $0 + $1.costBasis }.asCurrency()
                )
                AccountRow(icon: "chart.pie.fill", iconColor: EquityTheme.accent, title: "Positions", value: "\(service.portfolio.investments.count)")
            }
            .clipShape(.rect(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(EquityTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Settings")
                .padding(.bottom, 12)

            VStack(spacing: 2) {
                SettingsRow(icon: "bell.badge", title: "Notifications", color: EquityTheme.accent)
                SettingsRow(icon: "lock.shield", title: "Privacy & Security", color: EquityTheme.secondary)
                SettingsRow(icon: "creditcard", title: "Linked Accounts", color: EquityTheme.primary)
                SettingsRow(icon: "gearshape", title: "Preferences", color: EquityTheme.textSecondary)
                SettingsRow(icon: "questionmark.circle", title: "Help & Support", color: EquityTheme.warning)
                SettingsRow(icon: "info.circle", title: "About EquityFlow", color: EquityTheme.textSecondary)
            }
            .clipShape(.rect(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(EquityTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Sign Out
    private var signOutButton: some View {
        Button { showSignOutConfirmation = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.square")
                    .font(.system(size: 16, weight: .medium))
                Text("Sign Out")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(EquityTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(EquityTheme.danger.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(EquityTheme.danger.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Helpers
    private var userInitials: String {
        let name = authService.displayName
        let parts = name.components(separatedBy: " ")
        if parts.count >= 2 {
            return (parts[0].first.map(String.init) ?? "") + (parts[1].first.map(String.init) ?? "")
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Account Row
struct AccountRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var valueColor: Color = EquityTheme.textPrimary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(EquityTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(EquityTheme.card)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button {} label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))

                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(EquityTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(EquityTheme.card)
        }
    }
}
