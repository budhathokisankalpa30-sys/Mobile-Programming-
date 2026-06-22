//
//  FirebaseAuthService.swift
//  EquityFlow
//
//  Firebase Authentication service wrapping FirebaseAuth.
//

import Foundation
import FirebaseAuth
import FirebaseCore

enum AuthError: LocalizedError {
    case notConfigured
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case noUser

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Firebase is not configured. Add GoogleService-Info.plist to the project."
        case .signInFailed(let message):
            return message
        case .signUpFailed(let message):
            return message
        case .signOutFailed(let message):
            return message
        case .noUser:
            return "No authenticated user found."
        }
    }
}

@MainActor
@Observable
final class FirebaseAuthService {
    private(set) var user: FirebaseAuth.User?
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    private(set) var authError: String?

    var displayName: String {
        user?.displayName ?? user?.email?.components(separatedBy: "@").first ?? "Investor"
    }

    var email: String {
        user?.email ?? ""
    }

    var userId: String? {
        user?.uid
    }

    private var stateHandler: AuthStateDidChangeListenerHandle?

    init() {
        configureFirebase()
    }

    private func configureFirebase() {
        guard FirebaseApp.app() == nil else {
            attachAuthListener()
            return
        }
        #if DEBUG
        // Allow running without GoogleService-Info.plist in simulator/previews
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            self.isAuthenticated = false
            return
        }
        #endif
        FirebaseApp.configure()
        attachAuthListener()
    }

    private func attachAuthListener() {
        stateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        guard !email.isEmpty, !password.isEmpty else {
            authError = "Please enter your email and password."
            throw AuthError.signInFailed("Please enter your email and password.")
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            let message = (error as NSError).localizedDescription
            authError = message
            throw AuthError.signInFailed(message)
        }
    }

    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        guard !email.isEmpty, !password.isEmpty else {
            authError = "Please fill in all fields."
            throw AuthError.signUpFailed("Please fill in all fields.")
        }

        guard password.count >= 6 else {
            authError = "Password must be at least 6 characters."
            throw AuthError.signUpFailed("Password must be at least 6 characters.")
        }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name.isEmpty ? email.components(separatedBy: "@").first ?? "Investor" : name
            try await changeRequest.commitChanges()
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            let message = (error as NSError).localizedDescription
            authError = message
            throw AuthError.signUpFailed(message)
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            authError = (error as NSError).localizedDescription
            throw AuthError.signOutFailed((error as NSError).localizedDescription)
        }
    }
}
