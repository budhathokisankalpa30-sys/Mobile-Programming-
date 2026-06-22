//
//  EquityFlowApp.swift
//  EquityFlow
//

import SwiftUI
import FirebaseCore

@main
struct EquityFlowApp: App {
    @State private var authService = FirebaseAuthService()
    @State private var portfolioService = PortfolioService()
    @State private var firestoreService = FirestoreService()
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showLaunchScreen {
                    launchView
                        .task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showLaunchScreen = false
                            }
                        }
                } else if authService.isAuthenticated {
                    ContentView()
                        .environment(authService)
                        .environment(portfolioService)
                        .environment(firestoreService)
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                        .task {
                            // Load real Firestore data as soon as user is authenticated
                            if let userId = authService.userId {
                                await portfolioService.loadFromFirestore(
                                    userId: userId,
                                    firestoreService: firestoreService
                                )
                            }
                        }
                } else {
                    LoginView()
                        .environment(authService)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: authService.isAuthenticated)
            .animation(.easeInOut(duration: 0.4), value: showLaunchScreen)
        }
    }

    // MARK: - Launch Screen

    private var launchView: some View {
        ZStack {
            EquityTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(EquityTheme.walletGradient)
                        .frame(width: 90, height: 90)
                        .shadow(color: EquityTheme.primary.opacity(0.3), radius: 24, y: 8)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(.white)
                }

                Text("EquityFlow")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)

                Text("Invest Smarter, Grow Faster")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
            }
        }
    }
}
