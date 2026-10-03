//
//  PaginatorTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

@MainActor
struct PaginatorTests {

    @MainActor
    final class PageSource {
        var pages: [Int: Page] = [:]
        var errors: [Int: Error] = [:]
        var delayNanosecondsByPage: [Int: UInt64] = [:]
        private(set) var requestedPages: [Int] = []

        func fetch(_ page: Int) async throws -> Page {
            requestedPages.append(page)
            if let delay = delayNanosecondsByPage[page], delay > 0 {
                try await Task.sleep(nanoseconds: delay)
            }
            if let error = errors[page] {
                throw error
            }
            guard let result = pages[page] else {
                throw MockError.missingPage
            }
            return result
        }
    }

    enum MockError: Error {
        case missingPage
        case failed
    }

    let firstMovie = Movie(id: 1, title: "Toy Story", overview: "", posterPath: nil, releaseDate: nil)
    let secondMovie = Movie(id: 2, title: "Finding Nemo", overview: "", posterPath: nil, releaseDate: nil)
    let thirdMovie = Movie(id: 3, title: "Cars", overview: "", posterPath: nil, releaseDate: nil)

    private func makePaginator(_ source: PageSource, maxPages: Int = 500, prefetchDistance: Int = 1) -> Paginator<Movie> {
        Paginator<Movie>(maxPages: maxPages, prefetchDistance: prefetchDistance) { page in
            try await source.fetch(page)
        }
    }

    // MARK: - First page

    @Test
    func testLoadIfNeededLoadsFirstPage() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie])
        #expect(paginator.isLoaded)
        #expect(paginator.error == nil)
        #expect(source.requestedPages == [1])
    }

    @Test
    func testLoadIfNeededDoesNothingWhenAlreadyLoaded() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        paginator.loadIfNeeded()
        await Task.yield()

        #expect(source.requestedPages == [1])
    }

    @Test
    func testEmptyFirstPageSetsEmptyPhase() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        guard case .empty = paginator.phase else {
            Issue.record("Expected empty phase")
            return
        }
    }

    @Test
    func testFirstPageFailureSetsFailedPhase() async {
        let source = PageSource()
        source.errors[1] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        guard case .failed(let error) = paginator.phase else {
            Issue.record("Expected failed phase")
            return
        }
        #expect(error is MockError)
        #expect(paginator.items.isEmpty)
    }

    @Test
    func testRetryAfterFirstPageFailureLoadsFirstPage() async {
        let source = PageSource()
        source.errors[1] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        source.errors[1] = nil
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        paginator.retry()
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie])
        #expect(paginator.isLoaded)
        #expect(source.requestedPages == [1, 1])
    }

    // MARK: - Next pages

    @Test
    func testLoadMoreAppendsNextPage() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie, secondMovie])
        #expect(source.requestedPages == [1, 2])
    }

    @Test
    func testLoadMoreIgnoresItemsFarFromTheEnd() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie, secondMovie, thirdMovie], totalPages: 2)
        let paginator = makePaginator(source, prefetchDistance: 1)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await Task.yield()

        #expect(paginator.isLoadingMore == false)
        #expect(source.requestedPages == [1])
    }

    @Test
    func testLoadMoreDoesNothingAfterLastPage() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await Task.yield()

        #expect(paginator.canLoadMore == false)
        #expect(source.requestedPages == [1])
    }

    @Test
    func testLoadMoreRespectsMaxPages() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1000)
        let paginator = makePaginator(source, maxPages: 1)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await Task.yield()

        #expect(paginator.canLoadMore == false)
        #expect(source.requestedPages == [1])
    }

    @Test
    func testDuplicateLoadMoreRequestsLoadNextPageOnce() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 3)
        source.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 3)
        source.delayNanosecondsByPage[2] = 100_000_000
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        // Simulates onAppear firing twice for the last cell before page 2 arrives.
        paginator.loadMoreIfNeeded(after: firstMovie)
        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie, secondMovie])
        #expect(source.requestedPages == [1, 2])
    }

    @Test
    func testItemsAlreadyShownAreNotDuplicated() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie, secondMovie], totalPages: 2)
        source.pages[2] = Page(page: 2, results: [secondMovie, thirdMovie], totalPages: 2)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: secondMovie)
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie, secondMovie, thirdMovie])
    }

    @Test
    func testNextPageFailureKeepsItemsAndSetsError() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.errors[2] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie])
        #expect(paginator.error != nil)
        #expect(paginator.isLoaded)
    }

    @Test
    func testNoAutomaticLoadMoreWhileErrorIsShown() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.errors[2] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        paginator.loadMoreIfNeeded(after: firstMovie)
        await Task.yield()

        #expect(source.requestedPages == [1, 2])
    }

    @Test
    func testRetryAfterNextPageFailureLoadsTheSamePage() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.errors[2] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        source.errors[2] = nil
        source.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        paginator.retry()
        await waitUntilSettled(paginator)

        #expect(paginator.items == [firstMovie, secondMovie])
        #expect(paginator.error == nil)
        #expect(source.requestedPages == [1, 2, 2])
    }

    @Test
    func testClearErrorKeepsItems() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.errors[2] = MockError.failed
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        paginator.clearError()

        #expect(paginator.items == [firstMovie])
        #expect(paginator.error == nil)
    }

    // MARK: - Refresh & reset

    @Test
    func testRefreshReplacesItemsWithFirstPage() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        source.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        paginator.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(paginator)

        source.pages[1] = Page(page: 1, results: [thirdMovie], totalPages: 2)
        await paginator.refresh()

        #expect(paginator.items == [thirdMovie])
        #expect(source.requestedPages == [1, 2, 1])
    }

    @Test
    func testRefreshFailureKeepsItemsAndSetsError() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        source.errors[1] = MockError.failed
        await paginator.refresh()

        #expect(paginator.items == [firstMovie])
        #expect(paginator.error != nil)
        #expect(paginator.isLoaded)
    }

    @Test
    func testResetReturnsToIdle() async {
        let source = PageSource()
        source.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let paginator = makePaginator(source)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)

        paginator.reset()

        guard case .idle = paginator.phase else {
            Issue.record("Expected idle phase after reset")
            return
        }
        #expect(paginator.items.isEmpty)

        paginator.loadIfNeeded()
        await waitUntilSettled(paginator)
        #expect(source.requestedPages == [1, 1])
    }
}

// MARK: - Helpers

extension Paginator {
    var isLoaded: Bool {
        if case .loaded = phase { return true }
        return false
    }
}

/// Waits until neither the first page nor a next page is loading.
@MainActor
func waitUntilSettled<Item: Identifiable>(_ paginator: Paginator<Item>, timeout: TimeInterval = 3) async {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        let isLoadingFirstPage: Bool
        switch paginator.phase {
        case .idle, .loading: isLoadingFirstPage = true
        default: isLoadingFirstPage = false
        }
        if !isLoadingFirstPage && !paginator.isLoadingMore {
            return
        }
        await Task.yield()
    }
}
