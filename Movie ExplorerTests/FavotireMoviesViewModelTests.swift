//
//  FavotireMoviesViewModelTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 07.03.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

/// Pagination itself is covered by `PaginatorTests`; these tests check
/// authentication handling and the paginator wiring.
@MainActor
struct FavotireMoviesViewModelTests {

    final class MockFavoriteRepository: FavoriteRepository {
        var pages: [Int: Page] = [:]
        private(set) var requestedPages: [Int] = []

        func fetchFavoriteMovies(page: Int) async throws -> Page {
            requestedPages.append(page)
            guard let result = pages[page] else {
                Issue.record("Page \(page) not found")
                throw MockError.missingPage
            }
            return result
        }
    }

    final class MockAuthRepository: AuthRepository {
        var accountId: Int?
        var loginError: Error?
        var loginCallCount = 0

        var isLoggedIn: Bool { accountId != nil }

        func currentAccountId() -> Int? {
            accountId
        }

        func login() async throws {
            loginCallCount += 1
            if let loginError {
                throw loginError
            }
            accountId = accountId ?? 1
        }

        func logout() {
            accountId = nil
        }
    }

    enum MockError: Error {
        case missingPage
    }

    let firstMovie = Movie(id: 1, title: "Toy Story", overview: "", posterPath: nil, releaseDate: nil)
    let secondMovie = Movie(id: 2, title: "Finding Nemo", overview: "", posterPath: nil, releaseDate: nil)

    @Test
    func testIsAuthenticatedWhenLoggedIn() {
        let authRepository = MockAuthRepository()
        authRepository.accountId = 1

        let viewModel = FavotireMoviesViewModel(repository: MockFavoriteRepository(), authRepository: authRepository)

        #expect(viewModel.isAuthenticated)
    }

    @Test
    func testIsNotAuthenticatedWhenLoggedOut() {
        let viewModel = FavotireMoviesViewModel(repository: MockFavoriteRepository(), authRepository: MockAuthRepository())

        #expect(viewModel.isAuthenticated == false)
    }

    @Test
    func testMoviesLoadFavoritePages() async {
        let repository = MockFavoriteRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        repository.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)
        let authRepository = MockAuthRepository()
        authRepository.accountId = 1
        let viewModel = FavotireMoviesViewModel(repository: repository, authRepository: authRepository)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)
        viewModel.movies.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie, secondMovie])
        #expect(repository.requestedPages == [1, 2])
    }

    @Test
    func testLoginSuccessAuthenticatesAndResetsMovies() async {
        let repository = MockFavoriteRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let authRepository = MockAuthRepository()
        let viewModel = FavotireMoviesViewModel(repository: repository, authRepository: authRepository)

        viewModel.login()
        await waitUntil { viewModel.isAuthenticated }

        #expect(authRepository.loginCallCount == 1)
        #expect(viewModel.isAuthenticated)
        guard case .idle = viewModel.movies.phase else {
            Issue.record("Expected movies to wait for the screen to load them")
            return
        }
    }

    @Test
    func testLoginFailureStaysUnauthenticated() async {
        let authRepository = MockAuthRepository()
        authRepository.loginError = AuthError.cancelled
        let viewModel = FavotireMoviesViewModel(repository: MockFavoriteRepository(), authRepository: authRepository)

        viewModel.login()
        await waitUntil { authRepository.loginCallCount == 1 }
        await Task.yield()

        #expect(viewModel.isAuthenticated == false)
    }

    @Test
    func testUpdateAuthenticationAfterLogoutResetsMovies() async {
        let repository = MockFavoriteRepository()
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)
        let authRepository = MockAuthRepository()
        authRepository.accountId = 1
        let viewModel = FavotireMoviesViewModel(repository: repository, authRepository: authRepository)

        viewModel.movies.loadIfNeeded()
        await waitUntilSettled(viewModel.movies)

        authRepository.logout()
        viewModel.updateAuthentication()

        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.movies.items.isEmpty)
    }
}

@MainActor
private func waitUntil(timeout: TimeInterval = 3, _ condition: () -> Bool) async {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() && Date() < deadline {
        await Task.yield()
    }
}
