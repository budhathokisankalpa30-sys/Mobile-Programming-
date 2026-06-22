//
//  PortfolioService.swift
//  EquityFlow
//
//  Wires Firebase (Firestore) to live portfolio data.
//  Falls back to sample data when user has no Firestore records yet.
//

import Foundation

@MainActor
@Observable
final class PortfolioService {
    private(set) var portfolio: Portfolio
    private(set) var allocation: [AssetAllocation]
    private(set) var recentTransactions: [Transaction]
    private(set) var watchlist: [MarketItem]
    private(set) var isLoading = false

    // Stable sample history — generated once so chart doesn't jitter on refresh
    private static let stableHistory: [AllocationPoint] = {
        var rng = SeededRNG(seed: 42)
        let calendar = Calendar.current
        return (0..<24).map { i in
            let date = calendar.date(byAdding: .month, value: -23 + i, to: Date()) ?? Date()
            let base = 85_000.0
            let variation = rng.nextDouble(in: -0.08...0.12)
            return AllocationPoint(
                id: UUID(),
                date: date,
                value: base * (1.0 + Double(i - 12) * 0.03 + variation)
            )
        }
    }()

    init() {
        self.portfolio = PortfolioService.samplePortfolio()
        self.allocation = PortfolioService.sampleAllocation()
        self.recentTransactions = PortfolioService.sampleTransactions()
        self.watchlist = PortfolioService.sampleWatchlist()
    }

    // MARK: - Load from Firestore

    func loadFromFirestore(userId: String, firestoreService: FirestoreService) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let investments = try await firestoreService.fetchInvestments(userId: userId)
            let transactions = try await firestoreService.fetchTransactions(userId: userId)
            let remoteWatchlist = try await firestoreService.fetchWatchlist(userId: userId)

            // If user has remote investments, use those; otherwise keep sample
            if !investments.isEmpty {
                let total = investments.reduce(0) { $0 + $1.marketValue }
                let costBasis = investments.reduce(0) { $0 + $1.costBasis }
                let totalReturn = total - costBasis
                let totalReturnPct = costBasis > 0 ? (totalReturn / costBasis) * 100 : 0

                portfolio = Portfolio(
                    totalValue: total,
                    todayChange: total * 0.0142,
                    todayChangePercent: 1.42,
                    totalReturn: totalReturn,
                    totalReturnPercent: totalReturnPct,
                    investments: investments,
                    allocationHistory: Self.stableHistory
                )
                allocation = buildAllocation(from: investments)
            }

            if !transactions.isEmpty {
                recentTransactions = transactions
            }

            if !remoteWatchlist.isEmpty {
                watchlist = remoteWatchlist
            }

            // Seed Firestore with sample data if empty (first-time user)
            if investments.isEmpty {
                await seedFirestore(userId: userId, firestoreService: firestoreService)
            }

        } catch {
            // Network failure — silently keep sample data
        }
    }

    // MARK: - Seed sample data for new users

    private func seedFirestore(userId: String, firestoreService: FirestoreService) async {
        let sampleInvestments = PortfolioService.sampleInvestments()
        let sampleTransactions = PortfolioService.sampleTransactions()
        let sampleWatchlistItems = PortfolioService.sampleWatchlist()

        do {
            // Save profile
            try await firestoreService.saveUserProfile(
                userId: userId,
                displayName: "Investor",
                email: ""
            )

            for inv in sampleInvestments {
                try await firestoreService.saveInvestment(inv, userId: userId)
            }
            for tx in sampleTransactions where !tx.symbol.isEmpty {
                try await firestoreService.saveTransaction(tx, userId: userId)
            }
            for item in sampleWatchlistItems {
                try await firestoreService.saveWatchlistItem(item, userId: userId)
            }
        } catch {
            // Seeding failed; user will see sample data in-memory
        }
    }

    // MARK: - Refresh

    func refresh(userId: String? = nil, firestoreService: FirestoreService? = nil) async {
        isLoading = true
        defer { isLoading = false }

        if let userId, let firestoreService {
            await loadFromFirestore(userId: userId, firestoreService: firestoreService)
        } else {
            try? await Task.sleep(for: .milliseconds(800))
        }
    }

    // MARK: - Allocation helper

    private func buildAllocation(from investments: [Investment]) -> [AssetAllocation] {
        let total = investments.reduce(0) { $0 + $1.marketValue }
        let grouped = Dictionary(grouping: investments, by: { $0.type })
        return grouped.map { type, items in
            let value = items.reduce(0) { $0 + $1.marketValue }
            return AssetAllocation(
                id: UUID(),
                type: type,
                percentage: (value / total) * 100,
                value: value
            )
        }.sorted { $0.percentage > $1.percentage }
    }

    // MARK: - Sample Data

    static func samplePortfolio() -> Portfolio {
        let investments = sampleInvestments()
        let total = investments.reduce(0) { $0 + $1.marketValue }
        let costBasis = investments.reduce(0) { $0 + $1.costBasis }
        let totalReturn = total - costBasis
        let totalReturnPercent = costBasis > 0 ? (totalReturn / costBasis) * 100 : 0

        return Portfolio(
            totalValue: total,
            todayChange: total * 0.0142,
            todayChangePercent: 1.42,
            totalReturn: totalReturn,
            totalReturnPercent: totalReturnPercent,
            investments: investments,
            allocationHistory: stableHistory
        )
    }

    static func sampleInvestments() -> [Investment] {
        [
            Investment(id: UUID(), symbol: "AAPL", name: "Apple Inc.", type: .stock, shares: 45, avgCost: 178.50, currentPrice: 227.63, todayChange: 3.82, todayChangePercent: 1.71, totalReturn: 2210.85, totalReturnPercent: 27.54),
            Investment(id: UUID(), symbol: "MSFT", name: "Microsoft Corp.", type: .stock, shares: 28, avgCost: 392.10, currentPrice: 448.99, todayChange: 5.21, todayChangePercent: 1.17, totalReturn: 1592.92, totalReturnPercent: 14.51),
            Investment(id: UUID(), symbol: "SPY", name: "SPDR S&P 500 ETF", type: .etf, shares: 20, avgCost: 512.30, currentPrice: 554.72, todayChange: 3.15, todayChangePercent: 0.57, totalReturn: 848.40, totalReturnPercent: 8.28),
            Investment(id: UUID(), symbol: "BTC", name: "Bitcoin", type: .crypto, shares: 0.15, avgCost: 42300.00, currentPrice: 67850.00, todayChange: 1250.00, todayChangePercent: 1.88, totalReturn: 3832.50, totalReturnPercent: 60.40),
            Investment(id: UUID(), symbol: "ETH", name: "Ethereum", type: .crypto, shares: 2.5, avgCost: 2180.00, currentPrice: 3490.00, todayChange: 85.00, todayChangePercent: 2.50, totalReturn: 3275.00, totalReturnPercent: 60.09),
            Investment(id: UUID(), symbol: "NVDA", name: "NVIDIA Corp.", type: .stock, shares: 12, avgCost: 680.00, currentPrice: 895.30, todayChange: -12.40, todayChangePercent: -1.37, totalReturn: 2583.60, totalReturnPercent: 31.66),
            Investment(id: UUID(), symbol: "VTI", name: "Vanguard Total Stock", type: .etf, shares: 35, avgCost: 248.50, currentPrice: 270.18, todayChange: 1.92, todayChangePercent: 0.72, totalReturn: 758.80, totalReturnPercent: 8.73),
        ]
    }

    static func sampleAllocation() -> [AssetAllocation] {
        let investments = sampleInvestments()
        let total = investments.reduce(0) { $0 + $1.marketValue }
        let grouped = Dictionary(grouping: investments, by: { $0.type })
        return grouped.map { type, items in
            let value = items.reduce(0) { $0 + $1.marketValue }
            return AssetAllocation(id: UUID(), type: type, percentage: (value / total) * 100, value: value)
        }.sorted { $0.percentage > $1.percentage }
    }

    static func sampleTransactions() -> [Transaction] {
        [
            Transaction(id: UUID(), symbol: "AAPL", name: "Apple Inc.", type: .buy, shares: 5, price: 225.00, date: Date().addingTimeInterval(-3600 * 2)),
            Transaction(id: UUID(), symbol: "BTC", name: "Bitcoin", type: .buy, shares: 0.02, price: 66200.00, date: Date().addingTimeInterval(-3600 * 5)),
            Transaction(id: UUID(), symbol: "SPY", name: "SPDR S&P 500", type: .dividend, shares: 0, price: 124.50, date: Date().addingTimeInterval(-86400)),
            Transaction(id: UUID(), symbol: "NVDA", name: "NVIDIA Corp.", type: .sell, shares: 3, price: 890.00, date: Date().addingTimeInterval(-86400 * 2)),
            Transaction(id: UUID(), symbol: "", name: "Cash Deposit", type: .deposit, shares: 0, price: 5000.00, date: Date().addingTimeInterval(-86400 * 5)),
        ]
    }

    static func sampleWatchlist() -> [MarketItem] {
        [
            MarketItem(id: UUID(), symbol: "TSLA", name: "Tesla Inc.", price: 248.50, change: 4.20, changePercent: 1.72, type: .stock),
            MarketItem(id: UUID(), symbol: "AMZN", name: "Amazon.com Inc.", price: 187.35, change: -2.15, changePercent: -1.13, type: .stock),
            MarketItem(id: UUID(), symbol: "GOOGL", name: "Alphabet Inc.", price: 176.90, change: 1.80, changePercent: 1.03, type: .stock),
            MarketItem(id: UUID(), symbol: "QQQ", name: "Invesco QQQ Trust", price: 482.10, change: 5.30, changePercent: 1.11, type: .etf),
            MarketItem(id: UUID(), symbol: "SOL", name: "Solana", price: 142.75, change: 8.50, changePercent: 6.33, type: .crypto),
            MarketItem(id: UUID(), symbol: "META", name: "Meta Platforms", price: 512.40, change: 3.20, changePercent: 0.63, type: .stock),
        ]
    }
}

// MARK: - Seeded RNG (prevents jitter on re-render)

private struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) { self.state = seed }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        let raw = Double(next()) / Double(UInt64.max)
        return range.lowerBound + raw * (range.upperBound - range.lowerBound)
    }
}
