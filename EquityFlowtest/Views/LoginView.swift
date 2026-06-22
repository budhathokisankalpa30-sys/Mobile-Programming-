//
//  LoginView.swift
//  EquityFlow
//

import SwiftUI

struct LoginView: View {
    @Environment(FirebaseAuthService.self) private var authService
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var authError: String?

    var body: some View {
        ZStack {
            EquityTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    brandHeader

                    Spacer().frame(height: 48)

                    formCard

                    Spacer().frame(height: 16)

                    toggleModeButton

                    Spacer().frame(height: 48)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Brand Header

    private var brandHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EquityTheme.walletGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: EquityTheme.primary.opacity(0.3), radius: 20, y: 8)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 6) {
                Text("EquityFlow")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
                Text("The Stock Market for Human Potential")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 20) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(EquityTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isSignUp {
                inputField(icon: "person.fill", placeholder: "Full Name", text: $name, contentType: .name)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            inputField(icon: "envelope.fill", placeholder: "Email Address", text: $email, contentType: .emailAddress, keyboardType: .emailAddress)

            inputField(icon: "lock.fill", placeholder: "Password", text: $password, contentType: .password, isSecure: true)

            if let error = authError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 13))
                    Text(error).font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundStyle(EquityTheme.danger)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(EquityTheme.danger.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: 8) {
                    if isLoading { ProgressView().tint(.white) }
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(EquityTheme.primary)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.7 : 1)

            HStack(spacing: 12) {
                Rectangle().fill(EquityTheme.border).frame(height: 1)
                Text("or").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(EquityTheme.textSecondary)
                Rectangle().fill(EquityTheme.border).frame(height: 1)
            }

            socialButtons
        }
        .padding(24)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(EquityTheme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    // MARK: - Social Buttons (UI only for MVP)

    private var socialButtons: some View {
        HStack(spacing: 12) {
            socialButton(icon: "applelogo", title: "Apple")
            socialButton(icon: "g.circle.fill", title: "Google")
        }
    }

    private func socialButton(icon: String, title: String) -> some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 18, weight: .medium))
                Text(title).font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundStyle(EquityTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(EquityTheme.surface)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(EquityTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Toggle Mode

    private var toggleModeButton: some View {
        HStack(spacing: 4) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(EquityTheme.textSecondary)
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isSignUp.toggle()
                    authError = nil
                }
            } label: {
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(EquityTheme.primary)
            }
        }
    }

    // MARK: - Input Field

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(EquityTheme.textSecondary)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(EquityTheme.textPrimary)
            .tint(EquityTheme.primary)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(contentType == .emailAddress ? .never : .words)
            .autocorrectionDisabled(contentType == .emailAddress || isSecure)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(EquityTheme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(EquityTheme.border, lineWidth: 1))
    }

    // MARK: - Submit

    private func submit() async {
        authError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password, name: name)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            withAnimation { authError = error.localizedDescription }
        }
    }
}
