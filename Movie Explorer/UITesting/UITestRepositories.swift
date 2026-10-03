//
//  UITestRepositories.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 04.10.2026.
//

#if DEBUG
import Foundation
import Swinject

/// Replaces network-backed repositories with in-memory stubs for UI tests.
enum UITestDependencies {

    static func register(in container: Container) {
        let scenario = UITestConfiguration.scenario
        let auth = UITestAuthRepository(isLoggedIn: UITestConfiguration.isLoggedIn)

        container
            .register(AuthRepository.self) { _ in auth }
            .inObjectScope(.container)

        container
            .register(MoviesRepository.self) { _ in UITestMoviesRepository(scenario: scenario) }
            .inObjectScope(.container)

        container
            .register(FavoriteRepository.self) { _ in UITestFavoriteRepository(auth: auth, scenario: scenario) }
            .inObjectScope(.container)

        container
            .register(WatchListRepository.self) { _ in UITestWatchListRepository(auth: auth, scenario: scenario) }
            .inObjectScope(.container)

        container
            .register(MovieDetailRepository.self) { _ in UITestMovieDetailRepository(auth: auth) }
            .inObjectScope(.container)

        container
            .register(PersonRepository.self) { _ in UITestPersonRepository() }
            .inObjectScope(.container)

        container
            .register(SearchRepository.self) { _ in UITestSearchRepository() }
            .inObjectScope(.container)
    }
}

// MARK: - Auth

/// Login succeeds immediately, without the TMDB web flow.
final class UITestAuthRepository: AuthRepository {

    private(set) var isLoggedIn: Bool

    init(isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }

    func currentAccountId() -> Int? {
        isLoggedIn ? 1 : nil
    }

    func login() async throws {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }

    func requireLogin() throws {
        guard isLoggedIn else { throw AuthError.notAuthenticated }
    }
}

// MARK: - Movies

final class UITestMoviesRepository: MoviesRepository {

    private let scenario: UITestScenario
    private var failuresLeft: [Int: Int]

    init(scenario: UITestScenario) {
        self.scenario = scenario
        switch scenario {
        case .moviesFirstPageError: failuresLeft = [1: 1]
        case .moviesNextPageError: failuresLeft = [2: 1]
        default: failuresLeft = [:]
        }
    }

    func fetchMovies(page: Int) async throws -> Page {
        if let left = failuresLeft[page], left > 0 {
            failuresLeft[page] = left - 1
            throw ConnectionError.noInternet
        }
        switch page {
        case 1: return UITestFixtures.page(UITestFixtures.popularPage1, page: 1, totalPages: 2)
        default: return UITestFixtures.page(UITestFixtures.popularPage2, page: 2, totalPages: 2)
        }
    }

    func fetchMovies(page: Int, genre: Genres) async throws -> Page {
        UITestFixtures.page(UITestFixtures.genreMovies)
    }
}

// MARK: - Favorites & watch list

final class UITestFavoriteRepository: FavoriteRepository {

    private let auth: UITestAuthRepository
    private let scenario: UITestScenario

    init(auth: UITestAuthRepository, scenario: UITestScenario) {
        self.auth = auth
        self.scenario = scenario
    }

    func fetchFavoriteMovies(page: Int) async throws -> Page {
        try auth.requireLogin()
        return UITestFixtures.page(scenario == .emptyLists ? [] : UITestFixtures.favoriteMovies)
    }
}

final class UITestWatchListRepository: WatchListRepository {

    private let auth: UITestAuthRepository
    private let scenario: UITestScenario

    init(auth: UITestAuthRepository, scenario: UITestScenario) {
        self.auth = auth
        self.scenario = scenario
    }

    func fetchMovies(page: Int) async throws -> Page {
        try auth.requireLogin()
        return UITestFixtures.page(scenario == .emptyLists ? [] : UITestFixtures.watchListMovies)
    }
}

// MARK: - Movie details

final class UITestMovieDetailRepository: MovieDetailRepository {

    private let auth: UITestAuthRepository
    private var favorites: Set<Int> = []
    private var watchList: Set<Int> = []

    init(auth: UITestAuthRepository) {
        self.auth = auth
    }

    func getDetailsOfMovie(movieId: Int) async throws -> MovieDetails {
        let title = UITestFixtures.title(ofMovie: movieId)
        return MovieDetails(
            id: movieId,
            title: title,
            overview: "Overview of \(title)",
            genres: [UITestFixtures.genre],
            budget: 0,
            revenue: 0,
            status: "Released",
            releaseDate: nil,
            backdropPath: nil,
            posterPath: nil,
            voteAverage: 7.5
        )
    }

    func addToFavorites(movieId: Int) async throws -> Bool {
        try auth.requireLogin()
        favorites.insert(movieId)
        return true
    }

    func removeToFavorites(movieId: Int) async throws -> Bool {
        try auth.requireLogin()
        favorites.remove(movieId)
        return true
    }

    func addToWatchLater(movieId: Int) async throws -> Bool {
        try auth.requireLogin()
        watchList.insert(movieId)
        return true
    }

    func removeToWatchLater(movieId: Int) async throws -> Bool {
        try auth.requireLogin()
        watchList.remove(movieId)
        return true
    }

    func getMovieStatus(movieId: Int) async throws -> MovieStatus {
        try auth.requireLogin()
        return MovieStatus(id: movieId, favorite: favorites.contains(movieId), watchlist: watchList.contains(movieId))
    }

    func getImages(movieId: Int) async throws -> [Frame] {
        []
    }

    func getVideos(movieId: Int) async throws -> [Video] {
        [UITestFixtures.trailer]
    }

    func getCast(movieId: Int) async throws -> [Cast] {
        UITestFixtures.cast
    }

    func getSimilar(movieId: Int, page: Int) async throws -> Page {
        UITestFixtures.page(UITestFixtures.similarMovies)
    }
}

// MARK: - Person

final class UITestPersonRepository: PersonRepository {

    func getPerson(personId: Int) async throws -> Person {
        let name = UITestFixtures.name(ofPerson: personId)
        return Person(
            id: personId,
            name: name,
            profilePath: nil,
            biography: "Biography of \(name)",
            birthday: nil,
            deathday: nil,
            placeOfBirth: "Springfield"
        )
    }

    func getPersonImages(personId: Int) async throws -> [PersonImage] {
        []
    }

    func getMoviesWithPerson(personId: Int, page: Int) async throws -> Page {
        UITestFixtures.page(UITestFixtures.personMovies)
    }
}

// MARK: - Search

/// Any query returns the same results, except `UITestFixtures.emptySearchQuery`.
final class UITestSearchRepository: SearchRepository {

    func searchMovies(query: String, page: Int) async throws -> Page {
        UITestFixtures.page(isEmpty(query) ? [] : UITestFixtures.searchMovies)
    }

    func searchPersons(query: String, page: Int) async throws -> PersonsPage {
        PersonsPage(page: 1, results: isEmpty(query) ? [] : [UITestFixtures.searchPerson], totalPages: 1)
    }

    func searchKeywords(query: String, page: Int) async throws -> KeywordsPage {
        KeywordsPage(page: 1, results: isEmpty(query) ? [] : [UITestFixtures.searchKeyword], totalPages: 1)
    }

    private func isEmpty(_ query: String) -> Bool {
        query.localizedCaseInsensitiveContains(UITestFixtures.emptySearchQuery)
    }
}
#endif
