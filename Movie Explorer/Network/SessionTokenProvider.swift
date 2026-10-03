//
//  SessionTokenProvider.swift
//  Movie Explorer
//

import Foundation

nonisolated protocol SessionTokenProvider: Sendable {
    func currentBearerToken() -> String
}

nonisolated final class DefaultSessionTokenProvider: SessionTokenProvider {
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    func currentBearerToken() -> String {
        sessionStore.load()?.accessToken ?? AppConfig.apiKey
    }
}
