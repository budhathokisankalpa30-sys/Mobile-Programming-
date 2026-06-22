//
//  InvestmentsView.swift
//  EquityFlow
//

import SwiftUI

struct InvestmentsView: View {
    @Environment(PortfolioService.self) private var service
    @State private var selectedFilter: InvestmentType? = nil
    @State private var appeared = false

    private var filteredInvestments: [Investment] {
        if let filter = selectedFilter {
            return service.portfolio.investments.filter { $0.type == filter }
        }
        return service.portfolio.investments
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryBar
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)

                filterChips
                    .opacity(appeared ? 1 : 0)

                investmentsList
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

    // MARK: - Summary Bar
    private var summaryBar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                EquityTheme.caption(Text("My Holdings"))
                Text("\(service.portfolio.investments.count) positions")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                EquityTheme.caption(Text("Total Value"))
                Text(service.portfolio.formattedTotalValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(EquityTheme.primary)
            }
        }
        .padding(20)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(EquityTheme.border, lineWidth: 0.5))
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedFilter == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = nil }
                }
                ForEach(InvestmentType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.rawValue,
                        icon: type.icon,
                        color: Color(hex: type.color),
                        isSelected: selectedFilter == type
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = selectedFilter == type ? nil : type
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Investments List
    private var investmentsList: some View {
        VStack(spacing: 10) {
            if filteredInvestments.isEmpty {
                emptyState
            } else {
                ForEach(filteredInvestments) { investment in
                    InvestmentRow(investment: investment)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(EquityTheme.textSecondary)
            Text("No investments in this category")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(EquityTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 12, weight: .medium))
                }
                Text(title).font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? (color ?? EquityTheme.primary) : EquityTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? (color ?? EquityTheme.primary).opacity(0.15) : EquityTheme.surface)
            .clipShape(.capsule)
            .overlay(
                Capsule().stroke(
                    isSelected ? (color ?? EquityTheme.primary).opacity(0.4) : EquityTheme.border,
                    lineWidth: 1
                )
            )
        }
        .scaleEffect(isSelected ? 1.0 : 0.97)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
