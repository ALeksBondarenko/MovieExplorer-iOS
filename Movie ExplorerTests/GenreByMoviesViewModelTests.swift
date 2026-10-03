//
//  GenreByMoviesViewModelTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 07.03.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

/// Pagination itself is covered by `PaginatorTests`; these tests check that
/// the view model wires its paginator to the right repository call.
@MainActor
struct GenreByMoviesViewModelTests {

    final class MockMoviesRepository: MoviesRepository {
        var pages: [Int: Page] = [:]
        private(set) var requestedPages: [Int] = []
        private(set) var requestedGenres: [Genres] = []

        func fetchMovies(page: Int) async throws -> Page {
            Issue.record("Genre screen must not load popular movies")
            throw MockError.failed
        }

        func fetchMovies(page: Int, genre: Genres) async throws -> Page {
            requestedPages.append(page)
            requestedGenres.append(genre)
            guard let result = pages[page] else { throw MockError.failed }
            return result
        }
    }

    enum MockError: Error {
        case failed
    }

    let genre = Genres(id: 1, name: "adventure")
    let firstMovie = Movie(id: 1, title: "Toy Story", overview: "", posterPath: nil, releaseDate: Date())
    let secondMovie = Movie(id: 2, title: "Finding Nemo", overview: "", posterPath: nil, releaseDate: Date())

    @Test
    func testInitialTitleIsCapitalizedGenreName() {
        let viewModel = GenreByMoviesViewModel(repository: MockMoviesRepository(), genre: genre)

        #expect(viewModel.title == "Adventure")
    }

    @Test
    func testMoviesLoadFirstPageOfTheGenre() async {
        let repository = MockMoviesRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let viewModel = GenreByMoviesViewModel(repository: repository, genre: genre)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie])
        #expect(repository.requestedPages == [1])
        #expect(repository.requestedGenres == [genre])
    }

    @Test
    func testMoviesLoadNextPageOfTheGenre() async {
        let repository = MockMoviesRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        repository.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        let viewModel = GenreByMoviesViewModel(repository: repository, genre: genre)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)
        viewModel.movies.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie, secondMovie])
        #expect(repository.requestedPages == [1, 2])
        #expect(repository.requestedGenres == [genre, genre])
    }
}
