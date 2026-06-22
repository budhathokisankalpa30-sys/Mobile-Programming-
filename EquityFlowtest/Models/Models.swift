//
//  Models.swift
//  EquityFlow
//

import Foundation

// MARK: - Portfolio
struct Portfolio: Identifiable, Sendable {
    let id: String = "main"
    var totalValue: Double
    var todayChange: Double
    var todayChangePercent: Double
    var totalReturn: Double
    var totalReturnPercent: Double
    var investments: [Investment]
    var allocationHistory: [AllocationPoint]

    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: totalValue)) ?? "$0.00"
    }

    var formattedTodayChange: String {
        let prefix = todayChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", todayChange))"
    }

    var formattedTodayChangePercent: String {
        let prefix = todayChangePercent >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", todayChangePercent))%"
    }

    var isTodayPositive: Bool { todayChange >= 0 }
}

// MARK: - Investment
struct Investment: Identifiable, Hashable, Sendable {
    let id: UUID
    var symbol: String
    var name: String
    var type: InvestmentType
    var shares: Double
    var avgCost: Double
    var currentPrice: Double
    var todayChange: Double
    var todayChangePercent: Double
    var totalReturn: Double
    var totalReturnPercent: Double

    var marketValue: Double { shares * currentPrice }
    var costBasis: Double { shares * avgCost }

    var formattedMarketValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: marketValue)) ?? "$0.00"
    }

    var formattedCurrentPrice: String {
        String(format: "$%.2f", currentPrice)
    }

    var formattedChange: String {
        let prefix = todayChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", todayChange))"
    }

    var formattedChangePercent: String {
        let prefix = todayChangePercent >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", todayChangePercent))%"
    }

    var isPositive: Bool { todayChange >= 0 }
}

enum InvestmentType: String, CaseIterable, Sendable {
    case stock = "Stock"
    case etf = "ETF"
    case crypto = "Crypto"
    case bond = "Bond"
    case realEstate = "Real Estate"

    var icon: String {
        switch self {
        case .stock: return "building.2"
        case .etf: return "square.grid.2x2"
        case .crypto: return "bitcoinsign"
        case .bond: return "doc.text"
        case .realEstate: return "house"
        }
    }

    var color: String {
        switch self {
        case .stock: return "4D7CFE"
        case .etf: return "00C896"
        case .crypto: return "F5B700"
        case .bond: return "94A3B8"
        case .realEstate: return "F97316"
        }
    }
}

// MARK: - Asset Allocation
struct AssetAllocation: Identifiable, Sendable {
    let id: UUID
    var type: InvestmentType
    var percentage: Double
    var value: Double
}

// MARK: - Allocation History
struct AllocationPoint: Identifiable, Sendable {
    let id: UUID
    var date: Date
    var value: Double
}

// MARK: - Market Item (Watchlist)
struct MarketItem: Identifiable, Sendable {
    let id: UUID
    var symbol: String
    var name: String
    var price: Double
    var change: Double
    var changePercent: Double
    var type: InvestmentType

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    var formattedChange: String {
        let prefix = change >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", change))"
    }

    var formattedChangePercent: String {
        let prefix = changePercent >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", changePercent))%"
    }

    var isPositive: Bool { change >= 0 }
}

// MARK: - Transaction
struct Transaction: Identifiable, Sendable {
    let id: UUID
    var symbol: String
    var name: String
    var type: TransactionType
    var shares: Double
    var price: Double
    var date: Date
    var total: Double { shares * price }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

enum TransactionType: String, Sendable {
    case buy = "Buy"
    case sell = "Sell"
    case dividend = "Dividend"
    case deposit = "Deposit"
    case withdraw = "Withdraw"
}

// MARK: - Double currency helper (renamed to avoid stdlib conflict)
extension Double {
    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}
