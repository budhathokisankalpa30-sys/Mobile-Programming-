//
//  FirestoreService.swift
//  EquityFlow
//
//  Firestore-backed persistence for portfolio, investments, and transactions.
//

import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class FirestoreService {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private(set) var isSyncing = false
    private(set) var syncError: String?

    deinit {
        listener?.remove()
    }

    // MARK: - Save / Update

    func saveInvestment(_ investment: Investment, userId: String) async throws {
        let data = investment.dictionary
        try await db.collection("users")
            .document(userId)
            .collection("investments")
            .document(investment.id.uuidString)
            .setData(data, merge: true)
    }

    func deleteInvestment(_ id: UUID, userId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("investments")
            .document(id.uuidString)
            .delete()
    }

    func saveTransaction(_ transaction: Transaction, userId: String) async throws {
        let data = transaction.dictionary
        try await db.collection("users")
            .document(userId)
            .collection("transactions")
            .document(transaction.id.uuidString)
            .setData(data, merge: true)
    }

    func saveWatchlistItem(_ item: MarketItem, userId: String) async throws {
        let data = item.dictionary
        try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(item.id.uuidString)
            .setData(data, merge: true)
    }

    func saveUserProfile(userId: String, displayName: String, email: String) async throws {
        let data: [String: Any] = [
            "displayName": displayName,
            "email": email,
            "lastLogin": Date()
        ]
        try await db.collection("users")
            .document(userId)
            .setData(data, merge: true)
    }

    // MARK: - Fetch

    func fetchInvestments(userId: String) async throws -> [Investment] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("investments")
            .getDocuments()

        return snapshot.documents.compactMap { Investment(from: $0.data()) }
    }

    func fetchTransactions(userId: String) async throws -> [Transaction] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("transactions")
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { Transaction(from: $0.data()) }
    }

    func fetchWatchlist(userId: String) async throws -> [MarketItem] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .getDocuments()

        return snapshot.documents.compactMap { MarketItem(from: $0.data()) }
    }

    // MARK: - Real-time Listener

    func listenToInvestments(userId: String, onUpdate: @escaping ([Investment]) -> Void) {
        listener?.remove()
        listener = db.collection("users")
            .document(userId)
            .collection("investments")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let investments = documents.compactMap { Investment(from: $0.data()) }
                DispatchQueue.main.async { onUpdate(investments) }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

// MARK: - Dictionary Converters

extension Investment {
    var dictionary: [String: Any] {
        [
            "id": id.uuidString,
            "symbol": symbol,
            "name": name,
            "type": type.rawValue,
            "shares": shares,
            "avgCost": avgCost,
            "currentPrice": currentPrice,
            "todayChange": todayChange,
            "todayChangePercent": todayChangePercent,
            "totalReturn": totalReturn,
            "totalReturnPercent": totalReturnPercent
        ]
    }

    init?(from dict: [String: Any]) {
        guard
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let symbol = dict["symbol"] as? String,
            let name = dict["name"] as? String,
            let typeString = dict["type"] as? String,
            let type = InvestmentType(rawValue: typeString),
            let shares = dict["shares"] as? Double,
            let avgCost = dict["avgCost"] as? Double,
            let currentPrice = dict["currentPrice"] as? Double,
            let todayChange = dict["todayChange"] as? Double,
            let todayChangePercent = dict["todayChangePercent"] as? Double,
            let totalReturn = dict["totalReturn"] as? Double,
            let totalReturnPercent = dict["totalReturnPercent"] as? Double
        else { return nil }

        self.init(
            id: id, symbol: symbol, name: name, type: type,
            shares: shares, avgCost: avgCost, currentPrice: currentPrice,
            todayChange: todayChange, todayChangePercent: todayChangePercent,
            totalReturn: totalReturn, totalReturnPercent: totalReturnPercent
        )
    }
}

extension Transaction {
    var dictionary: [String: Any] {
        [
            "id": id.uuidString,
            "symbol": symbol,
            "name": name,
            "type": type.rawValue,
            "shares": shares,
            "price": price,
            "date": date
        ]
    }

    init?(from dict: [String: Any]) {
        guard
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let symbol = dict["symbol"] as? String,
            let name = dict["name"] as? String,
            let typeString = dict["type"] as? String,
            let type = TransactionType(rawValue: typeString),
            let shares = dict["shares"] as? Double,
            let price = dict["price"] as? Double,
            let date = dict["date"] as? Timestamp
        else { return nil }

        self.init(
            id: id, symbol: symbol, name: name, type: type,
            shares: shares, price: price, date: date.dateValue()
        )
    }
}

extension MarketItem {
    var dictionary: [String: Any] {
        [
            "id": id.uuidString,
            "symbol": symbol,
            "name": name,
            "price": price,
            "change": change,
            "changePercent": changePercent,
            "type": type.rawValue
        ]
    }

    init?(from dict: [String: Any]) {
        guard
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let symbol = dict["symbol"] as? String,
            let name = dict["name"] as? String,
            let price = dict["price"] as? Double,
            let change = dict["change"] as? Double,
            let changePercent = dict["changePercent"] as? Double,
            let typeString = dict["type"] as? String,
            let type = InvestmentType(rawValue: typeString)
        else { return nil }

        self.init(
            id: id, symbol: symbol, name: name, price: price,
            change: change, changePercent: changePercent, type: type
        )
    }
}
