//
//  Components.swift
//  EquityFlow
//

import SwiftUI

// MARK: - Portfolio Value Card
struct PortfolioValueCard: View {
    let portfolio: Portfolio
    let isLoading: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                EquityTheme.caption(Text("Total Portfolio Value"))
                Spacer()
                EquityTheme.caption(Text("All Accounts"))
            }

            if isLoading {
                ProgressView()
                    .tint(EquityTheme.primary)
                    .frame(height: 44)
            } else {
                EquityTheme.valueLarge(Text(portfolio.formattedTotalValue))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.5), value: portfolio.totalValue)
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    EquityTheme.caption(Text("Today"))
                    HStack(spacing: 4) {
                        Image(systemName: portfolio.isTodayPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                        Text(portfolio.formattedTodayChange)
                            .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                        Text("(\(portfolio.formattedTodayChangePercent))")
                            .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                    }
                    .foregroundStyle(portfolio.isTodayPositive ? EquityTheme.success : EquityTheme.danger)
                }

                Divider()
                    .frame(height: 32)
                    .background(EquityTheme.border)

                VStack(alignment: .leading, spacing: 4) {
                    EquityTheme.caption(Text("Total Return"))
                    HStack(spacing: 4) {
                        Image(systemName: portfolio.totalReturn >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                        Text("\(portfolio.totalReturn >= 0 ? "+" : "")\(String(format: "%.2f", portfolio.totalReturnPercent))%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    }
                    .foregroundStyle(portfolio.totalReturn >= 0 ? EquityTheme.success : EquityTheme.danger)
                }

                Spacer()
            }
        }
        .padding(24)
        .background(EquityTheme.walletGradient)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: EquityTheme.primary.opacity(0.2), radius: 16, y: 8)
    }
}

// MARK: - Investment Row
struct InvestmentRow: View {
    let investment: Investment

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: investment.type.color).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: investment.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: investment.type.color))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(investment.symbol)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
                Text(investment.name)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(investment.formattedCurrentPrice)
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(EquityTheme.textPrimary)
                HStack(spacing: 2) {
                    Text(investment.formattedChange)
                    Text("(\(investment.formattedChangePercent))")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(investment.isPositive ? EquityTheme.success : EquityTheme.danger)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(EquityTheme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Market Row
struct MarketRow: View {
    let item: MarketItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: item.type.color).opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: item.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: item.type.color))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.symbol)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
                Text(item.name)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.formattedPrice)
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(EquityTheme.textPrimary)
                HStack(spacing: 2) {
                    Text(item.formattedChange)
                    Text("(\(item.formattedChangePercent))")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(item.isPositive ? EquityTheme.success : EquityTheme.danger)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(EquityTheme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction

    var icon: String {
        switch transaction.type {
        case .buy: return "arrow.down.circle"
        case .sell: return "arrow.up.circle"
        case .dividend: return "dollarsign.circle"
        case .deposit: return "plus.circle"
        case .withdraw: return "minus.circle"
        }
    }

    var iconColor: Color {
        switch transaction.type {
        case .buy: return EquityTheme.primary
        case .sell: return EquityTheme.danger
        case .dividend: return EquityTheme.accent
        case .deposit: return EquityTheme.success
        case .withdraw: return EquityTheme.warning
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.symbol.isEmpty ? transaction.name : "\(transaction.symbol) • \(transaction.type.rawValue)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(EquityTheme.textPrimary)
                Text(transaction.formattedDate)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(EquityTheme.textSecondary)
            }

            Spacer()

            if transaction.shares > 0 {
                Text("\(String(format: "%.4f", transaction.shares)) shares")
                    .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(EquityTheme.textSecondary)
            }

            Text(transaction.formattedTotal)
                .font(.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(EquityTheme.textPrimary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(EquityTheme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(EquityTheme.textPrimary)
            Spacer()
            if let action, let onAction {
                Button(action: onAction) {
                    Text(action)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(EquityTheme.primary)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Line Chart
struct PortfolioLineChart: View {
    let data: [AllocationPoint]
    let lineColor: Color

    private var minValue: Double { (data.map(\.value).min() ?? 0) * 0.95 }
    private var maxValue: Double { (data.map(\.value).max() ?? 1) * 1.05 }
    private var range: Double { maxValue - minValue }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = data.count > 1 ? width / CGFloat(data.count - 1) : width

            ZStack {
                ForEach(0..<4) { i in
                    let y = height * CGFloat(i) / 3
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(EquityTheme.border.opacity(0.3), lineWidth: 0.5)
                }

                if data.count > 1 {
                    Path { path in
                        for (i, point) in data.enumerated() {
                            let x = CGFloat(i) * stepX
                            let y = height - CGFloat((point.value - minValue) / range) * height
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                        path.closeSubpath()
                    }
                    .fill(LinearGradient(colors: [lineColor.opacity(0.2), lineColor.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                }

                if data.count > 1 {
                    Path { path in
                        for (i, point) in data.enumerated() {
                            let x = CGFloat(i) * stepX
                            let y = height - CGFloat((point.value - minValue) / range) * height
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                }

                if let last = data.last {
                    let x = width
                    let y = height - CGFloat((last.value - minValue) / range) * height
                    Circle()
                        .fill(lineColor)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().fill(.white.opacity(0.3)).frame(width: 4, height: 4))
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Allocation Donut Chart
struct AllocationDonutChart: View {
    let allocations: [AssetAllocation]

    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                ForEach(Array(allocations.enumerated()), id: \.element.id) { index, allocation in
                    DonutSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: Color(hex: allocation.type.color)
                    )
                }
                VStack(spacing: 2) {
                    Text("\(allocations.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(EquityTheme.textPrimary)
                    Text("Assets")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(EquityTheme.textSecondary)
                }
            }
            .frame(width: 110, height: 110)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(allocations) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: item.type.color))
                            .frame(width: 10, height: 10)
                        Text(item.type.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(EquityTheme.textPrimary)
                        Spacer()
                        Text(String(format: "%.1f%%", item.percentage))
                            .font(.system(size: 14, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(EquityTheme.textSecondary)
                    }
                }
            }
        }
        .padding(20)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(EquityTheme.border, lineWidth: 1))
    }

    private func startAngle(for index: Int) -> Angle {
        let total = allocations.reduce(0) { $0 + $1.percentage }
        let previous = allocations.prefix(index).reduce(0) { $0 + $1.percentage }
        return .degrees((previous / total) * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let total = allocations.reduce(0) { $0 + $1.percentage }
        let cumulative = allocations.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return .degrees((cumulative / total) * 360 - 90)
    }
}

struct DonutSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let innerRadius = radius * 0.6

            Path { path in
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            .fill(color)
            .overlay(
                Path { path in
                    path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                    path.closeSubpath()
                }
                .stroke(EquityTheme.background, lineWidth: 2)
            )
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let isPositive: Bool
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            EquityTheme.caption(Text(title))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(color)

            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundStyle(isPositive ? EquityTheme.success : EquityTheme.danger)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EquityTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(EquityTheme.border, lineWidth: 0.5)
        )
    }
}
