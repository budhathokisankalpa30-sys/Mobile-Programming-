//
//  DashboardView.swift
//  EquityFlow
//

import SwiftUI

struct DashboardView: View {
    @Environment(PortfolioService.self) private var service
    @Environment(FirebaseAuthService.self) private var authService
    @Environment(FirestoreService.self) private var firestoreService
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -20)

                PortfolioValueCard(
                    portfolio: service.portfolio,
                    isLoading: service.isLoading
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                quickStatsSection
                    .opacity(appeared ? 1 : 0)

                chartSection
                    .opacity(appeared ? 1 : 0)

                allocationSection
                    .opacity(appeared ? 1 : 0)

                recentActivitySection
                    .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(EquityTheme.backgroundGradient)
        .scrollIndicators(.hidden)
        .refreshable {
            await service.refresh(
                userId: authService.userId,
                firestoreService: firestoreService
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) { appeared = true }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(greeting()),")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
                Text(authService.displayName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
            }

            Spacer()

            Button {
                // Notifications (future)
            } label: {
                ZStack {
                    Circle()
                        .fill(EquityTheme.surface)
                        .frame(width: 44, height: 44)
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(EquityTheme.textPrimary)
                    Circle()
                        .fill(EquityTheme.primary)
                        .frame(width: 8, height: 8)
                        .offset(x: 10, y: -10)
                }
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        let costBasis = service.portfolio.investments.reduce(0) { $0 + $1.costBasis }

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ],
            spacing: 12
        ) {
            StatCard(
                title: "Invested",
                value: costBasis.asCurrency(),
                subtitle: "All time",
                isPositive: true,
                color: EquityTheme.secondary
            )
            StatCard(
                title: "24h Change",
                value: service.portfolio.formattedTodayChange,
                subtitle: service.portfolio.formattedTodayChangePercent,
                isPositive: service.portfolio.isTodayPositive,
                color: service.portfolio.isTodayPositive ? EquityTheme.success : EquityTheme.danger
            )
            StatCard(
                title: "Total Return",
                value: "\(service.portfolio.totalReturn >= 0 ? "+" : "")\(String(format: "%.2f", service.portfolio.totalReturnPercent))%",
                subtitle: service.portfolio.totalReturn.asCurrency(),
                isPositive: service.portfolio.totalReturn >= 0,
                color: service.portfolio.totalReturn >= 0 ? EquityTheme.success : EquityTheme.danger
            )
            StatCard(
                title: "Holdings",
                value: "\(service.portfolio.investments.count)",
                subtitle: "Positions",
                isPositive: true,
                color: EquityTheme.accent
            )
        }
    }

    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Portfolio Performance", action: "1Y", onAction: {})

            PortfolioLineChart(
                data: service.portfolio.allocationHistory,
                lineColor: EquityTheme.chartPositive
            )
            .frame(height: 180)
            .padding(.vertical, 20)

            HStack {
                ForEach(["1W", "1M", "3M", "6M", "1Y", "ALL"], id: \.self) { period in
                    Text(period)
                        .font(.system(size: 12, weight: period == "1Y" ? .bold : .medium, design: .rounded))
                        .foregroundStyle(period == "1Y" ? EquityTheme.primary : EquityTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(EquityTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Allocation Section
    private var allocationSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Asset Allocation")
                .padding(.bottom, 12)
            AllocationDonutChart(allocations: service.allocation)
        }
    }

    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Recent Activity", action: "See All", onAction: {})
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                ForEach(service.recentTransactions.prefix(4)) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }

    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
}
