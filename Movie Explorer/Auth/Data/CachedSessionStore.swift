//
//  CachedSessionStore.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 03.10.2026.
//

import Foundation

final class CachedSessionStore: SessionStore, @unchecked Sendable {

    private enum Cache {
        case notLoaded
        case loaded(AuthSession?)
    }

    private let wrapped: SessionStore
    private let lock = NSLock()
    private var cache: Cache = .notLoaded

    init(wrapping wrapped: SessionStore) {
        self.wrapped = wrapped
    }

    func load() -> AuthSession? {
        lock.withLock {
            if case .loaded(let session) = cache {
                return session
            }
            let session = wrapped.load()
            cache = .loaded(session)
            return session
        }
    }

    func save(_ session: AuthSession) {
        lock.withLock {
            wrapped.save(session)
            cache = .loaded(session)
        }
    }

    func clear() {
        lock.withLock {
            wrapped.clear()
            cache = .loaded(nil)
        }
    }
}
