//
//  MarketView.swift
//  EquityFlow
//

import SwiftUI

struct MarketView: View {
    @Environment(PortfolioService.self) private var service
    @State private var searchText = ""
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Market sentiment bar
                sentimentBar
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)

                // Search bar
                searchField
                    .opacity(appeared ? 1 : 0)

                // Market indices
                marketIndices
                    .opacity(appeared ? 1 : 0)

                // Watchlist
                watchlistSection
                    .opacity(appeared ? 1 : 0)
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
    }

    // MARK: - Sentiment Bar
    private var sentimentBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                EquityTheme.caption(Text("Market"))
                Text("Markets")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
            }
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(EquityTheme.success)
                    .frame(width: 8, height: 8)
                Text("Bullish")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(EquityTheme.success)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(EquityTheme.success.opacity(0.1))
            .clipShape(.capsule)
        }
    }

    // MARK: - Search Field
    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(EquityTheme.textSecondary)
            TextField("Search stocks, ETFs, crypto...", text: $searchText)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(EquityTheme.textPrimary)
                .tint(EquityTheme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(EquityTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Market Indices
    private var marketIndices: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Indices")
                .padding(.bottom, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    IndexCard(
                        symbol: "S&P 500",
                        value: "5,431.60",
                        change: "+0.87%",
                        isPositive: true
                    )
                    IndexCard(
                        symbol: "NASDAQ",
                        value: "19,753.19",
                        change: "+1.24%",
                        isPositive: true
                    )
                    IndexCard(
                        symbol: "DOW 30",
                        value: "38,798.99",
                        change: "-0.32%",
                        isPositive: false
                    )
                    IndexCard(
                        symbol: "VIX",
                        value: "13.45",
                        change: "-0.52%",
                        isPositive: true
                    )
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Watchlist
    private var watchlistSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Watchlist", action: "Edit", onAction: {})
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                ForEach(service.watchlist) { item in
                    MarketRow(item: item)
                }
            }
        }
    }
}

// MARK: - Index Card
struct IndexCard: View {
    let symbol: String
    let value: String
    let change: String
    let isPositive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(symbol)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(EquityTheme.textSecondary)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(EquityTheme.textPrimary)

            Text(change)
                .font(.system(size: 14, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(isPositive ? EquityTheme.success : EquityTheme.danger)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background((isPositive ? EquityTheme.success : EquityTheme.danger).opacity(0.1))
                .clipShape(.capsule)
        }
        .padding(16)
        .frame(width: 160)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(EquityTheme.border, lineWidth: 0.5)
        )
    }
}
