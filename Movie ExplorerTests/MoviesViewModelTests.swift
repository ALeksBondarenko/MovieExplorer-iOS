//
//  MoviesViewModelTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 25.01.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

/// Pagination itself is covered by `PaginatorTests`; these tests check that
/// the view model wires its paginator to the right repository call.
@MainActor
struct MoviesViewModelTests {
    let firstMovie = Movie(id: 1, title: "Toy Story", overview: "", posterPath: "/posterPath.jpg", releaseDate: Date())
    let secondMovie = Movie(id: 2, title: "Hoppers", overview: "", posterPath: "/posterPath.jpg", releaseDate: Date())

    final class MockMoviesRepository: MoviesRepository {
        var pages = [Int: Page]()
        private(set) var requestedPages: [Int] = []
        private(set) var requestedGenrePages: [Int] = []

        func fetchMovies(page: Int) async throws -> Page {
            requestedPages.append(page)
            guard let result = pages[page] else { throw MockError.error }
            return result
        }

        func fetchMovies(page: Int, genre: Genres) async throws -> Page {
            requestedGenrePages.append(page)
            guard let result = pages[page] else { throw MockError.error }
            return result
        }
    }

    enum MockError: Error {
        case error
    }

    @Test func testMoviesLoadFirstPageFromPopularMovies() async {
        let repository = MockMoviesRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let viewModel = MoviesViewModel(repository: repository)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie])
        #expect(repository.requestedPages == [1])
        #expect(repository.requestedGenrePages.isEmpty)
    }

    @Test func testMoviesLoadNextPage() async {
        let repository = MockMoviesRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        repository.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        let viewModel = MoviesViewModel(repository: repository)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)
        viewModel.movies.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie, secondMovie])
        #expect(repository.requestedPages == [1, 2])
    }
}
