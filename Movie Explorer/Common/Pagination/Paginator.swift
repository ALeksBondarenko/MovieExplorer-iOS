//
//  Paginator.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import Foundation
import Observation

@Observable
final class Paginator<Item: Identifiable> {

    enum Phase {
        case idle
        case loading
        case loaded
        case empty
        case failed(Error)
    }

    private(set) var items: [Item] = []
    private(set) var phase: Phase = .idle
    private(set) var isLoadingMore = false
    private(set) var error: Error?

    private var page = 0
    private var totalPages = 1

    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private let maxPages: Int
    @ObservationIgnored private let prefetchDistance: Int
    @ObservationIgnored private let fetch: (Int) async throws -> (items: [Item], page: Int?, totalPages: Int)

    init<Response: PageResponse>(
        maxPages: Int = 500,
        prefetchDistance: Int = 6,
        fetch: @escaping (Int) async throws -> Response
    ) where Response.Item == Item {
        self.maxPages = maxPages
        self.prefetchDistance = prefetchDistance
        self.fetch = { page in
            let response = try await fetch(page)
            return (response.results, response.page, response.totalPages)
        }
    }

    var canLoadMore: Bool {
        page < min(totalPages, maxPages)
    }

    func loadIfNeeded() {
        guard case .idle = phase else { return }
        phase = .loading
        start(page: 1, replacing: true)
    }

    func refresh() async {
        task?.cancel()
        isLoadingMore = false
        if items.isEmpty {
            phase = .loading
        }
        await run(page: 1, replacing: true)
    }

    func loadMoreIfNeeded(after item: Item) {
        guard items.suffix(prefetchDistance).contains(where: { $0.id == item.id }) else { return }
        loadMore()
    }

    func retry() {
        if case .failed = phase {
            phase = .loading
            start(page: 1, replacing: true)
        } else {
            error = nil
            loadMore()
        }
    }

    func clearError() {
        error = nil
    }

    func reset() {
        task?.cancel()
        task = nil
        items = []
        page = 0
        totalPages = 1
        isLoadingMore = false
        error = nil
        phase = .idle
    }

    private func loadMore() {
        guard case .loaded = phase, canLoadMore, !isLoadingMore, error == nil else { return }
        isLoadingMore = true
        start(page: page + 1, replacing: false)
    }

    private func start(page: Int, replacing: Bool) {
        task?.cancel()
        task = Task { [weak self] in
            await self?.run(page: page, replacing: replacing)
        }
    }

    private func run(page nextPage: Int, replacing: Bool) async {
        do {
            let result = try await fetch(nextPage)
            try Task.checkCancellation()

            if replacing {
                items = []
            }
            let existingIDs = Set(items.map(\.id))
            items += result.items.filter { !existingIDs.contains($0.id) }
            page = result.page ?? nextPage
            totalPages = result.totalPages
            error = nil
            isLoadingMore = false
            phase = items.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            // A newer request replaced this one, it must not touch the state.
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            log(error)
            isLoadingMore = false
            if items.isEmpty {
                phase = .failed(error)
            } else {
                self.error = error
            }
        }
    }
}
