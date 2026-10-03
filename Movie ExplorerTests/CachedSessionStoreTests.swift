//
//  CachedSessionStoreTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 03.10.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

struct CachedSessionStoreTests {

    final class CountingSessionStore: SessionStore, @unchecked Sendable {
        private let lock = NSLock()
        private var stored: AuthSession?
        private(set) var loadCount = 0
        private(set) var saveCount = 0
        private(set) var clearCount = 0

        init(stored: AuthSession? = nil) {
            self.stored = stored
        }

        func load() -> AuthSession? {
            lock.withLock {
                loadCount += 1
                return stored
            }
        }

        func save(_ session: AuthSession) {
            lock.withLock {
                saveCount += 1
                stored = session
            }
        }

        func clear() {
            lock.withLock {
                clearCount += 1
                stored = nil
            }
        }
    }

    let session = AuthSession(accessToken: "token", accountId: 1)

    @Test
    func testLoadReadsWrappedStoreOnlyOnce() {
        let wrapped = CountingSessionStore(stored: session)
        let store = CachedSessionStore(wrapping: wrapped)

        #expect(store.load() == session)
        #expect(store.load() == session)
        #expect(store.load() == session)

        #expect(wrapped.loadCount == 1)
    }

    @Test
    func testMissingSessionIsCachedToo() {
        let wrapped = CountingSessionStore(stored: nil)
        let store = CachedSessionStore(wrapping: wrapped)

        #expect(store.load() == nil)
        #expect(store.load() == nil)

        #expect(wrapped.loadCount == 1)
    }

    @Test
    func testSaveUpdatesCacheAndWrappedStore() {
        let wrapped = CountingSessionStore(stored: nil)
        let store = CachedSessionStore(wrapping: wrapped)
        _ = store.load()

        store.save(session)

        #expect(store.load() == session)
        #expect(wrapped.saveCount == 1)
        #expect(wrapped.loadCount == 1)
    }

    @Test
    func testClearUpdatesCacheAndWrappedStore() {
        let wrapped = CountingSessionStore(stored: session)
        let store = CachedSessionStore(wrapping: wrapped)
        _ = store.load()

        store.clear()

        #expect(store.load() == nil)
        #expect(wrapped.clearCount == 1)
        #expect(wrapped.loadCount == 1)
    }

    @Test
    func testConcurrentLoadsReadWrappedStoreOnce() async {
        let wrapped = await CountingSessionStore(stored: session)
        let store = await CachedSessionStore(wrapping: wrapped)

        await withTaskGroup(of: AuthSession?.self) { group in
            for _ in 0..<50 {
                group.addTask { await store.load() }
            }
            for await loaded in group {
                #expect(loaded == session)
            }
        }

        #expect(wrapped.loadCount == 1)
    }
}
