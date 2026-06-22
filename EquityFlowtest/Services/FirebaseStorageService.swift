//
//  FirebaseStorageService.swift
//  EquityFlow
//
//  Firebase Storage service for user-uploaded content like avatars and documents.
//

import Foundation
import FirebaseStorage

enum StorageError: LocalizedError {
    case uploadFailed(String)
    case downloadFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .uploadFailed(let message): return message
        case .downloadFailed(let message): return message
        case .deleteFailed(let message): return message
        }
    }
}

@MainActor
@Observable
final class FirebaseStorageService {
    private let storage = Storage.storage().reference()

    // MARK: - Avatar

    func uploadAvatar(userId: String, data: Data) async throws -> URL {
        let ref = storage.child("users/\(userId)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        do {
            _ = try await ref.putData(data, metadata: metadata)
            let url = try await ref.downloadURL()
            return url
        } catch {
            throw StorageError.uploadFailed((error as NSError).localizedDescription)
        }
    }

    func downloadAvatar(userId: String) async throws -> Data {
        let ref = storage.child("users/\(userId)/avatar.jpg")

        do {
            return try await ref.data(maxSize: 5 * 1024 * 1024)
        } catch {
            throw StorageError.downloadFailed((error as NSError).localizedDescription)
        }
    }

    func avatarURL(userId: String) async throws -> URL {
        let ref = storage.child("users/\(userId)/avatar.jpg")
        return try await ref.downloadURL()
    }

    func deleteAvatar(userId: String) async throws {
        let ref = storage.child("users/\(userId)/avatar.jpg")
        do {
            try await ref.delete()
        } catch {
            throw StorageError.deleteFailed((error as NSError).localizedDescription)
        }
    }

    // MARK: - Documents

    func uploadDocument(userId: String, fileName: String, data: Data, contentType: String) async throws -> URL {
        let ref = storage.child("users/\(userId)/documents/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = contentType

        do {
            _ = try await ref.putData(data, metadata: metadata)
            return try await ref.downloadURL()
        } catch {
            throw StorageError.uploadFailed((error as NSError).localizedDescription)
        }
    }

    func deleteDocument(userId: String, fileName: String) async throws {
        let ref = storage.child("users/\(userId)/documents/\(fileName)")
        do {
            try await ref.delete()
        } catch {
            throw StorageError.deleteFailed((error as NSError).localizedDescription)
        }
    }
}