//
//  ContentView.swift
//  EquityFlow
//
//  Main tab navigation for the EquityFlow fintech app.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case dashboard
    case investments
    case market
    case profile

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .investments: return "chart.bar"
        case .market: return "globe.americas"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .investments: return "chart.bar.fill"
        case .market: return "globe.americas.fill"
        case .profile: return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .investments: return "Holdings"
        case .market: return "Market"
        case .profile: return "Profile"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(AppTab.dashboard)

                InvestmentsView()
                    .tag(AppTab.investments)

                MarketView()
                    .tag(AppTab.market)

                ProfileView()
                    .tag(AppTab.profile)
            }
            .tabViewStyle(.tabBarOnly)

            customTabBar
        }
        .preferredColorScheme(.dark)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) { appeared = true }
        }
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? EquityTheme.primary : Color(hex: "94A3B8"))
                            .symbolEffect(.bounce, value: selectedTab == tab)

                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .medium, design: .rounded))
                            .foregroundStyle(selectedTab == tab ? EquityTheme.primary : Color(hex: "94A3B8"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(EquityTheme.card)
                .shadow(color: .black.opacity(0.5), radius: 20, y: -4)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(EquityTheme.border.opacity(0.5))
                .frame(height: 0.5)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
