//
//  WatchListViewModel.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 30.12.2025.
//

import Foundation
import Combine

@MainActor
final class WatchListViewModel: ViewModel {

    private let authRepository: AuthRepository

    @Published private(set) var isAuthenticated: Bool
    let movies: Paginator<Movie>

    init(repository: WatchListRepository, authRepository: AuthRepository) {
        self.authRepository = authRepository
        self.isAuthenticated = authRepository.isLoggedIn
        self.movies = Paginator<Movie> { [repository] page in
            try await repository.fetchMovies(page: page)
        }
    }

    /// Re-reads the session, e.g. after logging in or out from another screen.
    func updateAuthentication() {
        let isLoggedIn = authRepository.isLoggedIn
        if isLoggedIn != isAuthenticated {
            movies.reset()
        }
        isAuthenticated = isLoggedIn
    }

    func login() {
        addTask { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.authRepository.login()
                self.movies.reset()
                self.isAuthenticated = true
            } catch {
                log(error)
                self.isAuthenticated = false
            }
        }
    }
}
