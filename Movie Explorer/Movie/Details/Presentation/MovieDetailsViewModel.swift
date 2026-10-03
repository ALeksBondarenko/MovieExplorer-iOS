//
//  MovieDetailsViewModel.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 09.12.2025.
//
import Foundation
import Combine

@MainActor
final class MovieDetailsViewModel: ViewModel {
    private let repository: MovieDetailRepository
    private let authRepository: AuthRepository
    let movie: Movie
    @Published private(set) var state: MovieDetailsState = .loading
    @Published private(set) var title: String = ""
    let similar: Paginator<Movie>

    init(repository: MovieDetailRepository, authRepository: AuthRepository, movie: Movie) {
        self.repository = repository
        self.authRepository = authRepository
        self.movie = movie
        self.title = movie.title
        self.similar = Paginator<Movie> { [repository, movieId = movie.id] page in
            try await repository.getSimilar(movieId: movieId, page: page)
        }
    }

    /// Loads the details once; returning to the screen does not reload them.
    func requestDetails() {
        similar.loadIfNeeded()
        if case .success = state { return }
        addTask { @MainActor [weak self] in
            guard let self else { return }
            do {
                async let detailsResult = self.repository.getDetailsOfMovie(movieId: self.movie.id)
                async let videosResult = self.repository.getVideos(movieId: self.movie.id)
                async let imagesResult = self.repository.getImages(movieId: self.movie.id)
                async let castsResult = self.repository.getCast(movieId: self.movie.id)
                async let statusResult = self.currentMovieStatus()

                let (movieDetails, videos, images, casts, status) = try await (detailsResult, videosResult, imagesResult, castsResult, statusResult)

                self.state = .success(
                    movieDetails,
                    images,
                    videos.filter { $0.type == "Trailer" && $0.site == "YouTube" },
                    casts,
                    favorite: status?.favorite ?? false,
                    watchLater: status?.watchlist ?? false
                )
            } catch {
                self.state = .failure(error)
            }
        }
    }

    /// Repeats the failed load.
    func retry() {
        state = .loading
        requestDetails()
    }

    private func currentMovieStatus() async throws -> MovieStatus? {
        do {
            return try await self.repository.getMovieStatus(movieId: self.movie.id)
        } catch AuthError.notAuthenticated {
            return nil
        }
    }

    private func withAuthRetry<T>(_ operation: @Sendable () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch AuthError.notAuthenticated {
            try await authRepository.login()
            return try await operation()
        }
    }
    
    func toggleFavorites() {
        addTask { @MainActor [weak self] in
            guard let self else { return }
            guard case .success(let movie, let photos, let videos, let casts, let favorite, let watchLater) = self.state else {
                return
            }
            do {
                let isFavorite = try await self.withAuthRetry {
                    if favorite {
                        return try await !self.repository.removeToFavorites(movieId: self.movie.id)
                    } else {
                        return try await self.repository.addToFavorites(movieId: self.movie.id)
                    }
                }
                self.state = .success(movie, photos, videos, casts, favorite: isFavorite, watchLater: watchLater)
            } catch {
                log(error)
                self.state = .failure(error)
            }
        }
    }

    func toggleWatchLater() {
        addTask { @MainActor [weak self] in
            guard let self else { return }
            guard case .success(let movie, let photos, let videos, let casts, let favorite, let watchLater) = self.state else {
                return
            }
            do {
                let isWatchLater = try await self.withAuthRetry {
                    if watchLater {
                        return try await !self.repository.removeToWatchLater(movieId: self.movie.id)
                    } else {
                        return try await self.repository.addToWatchLater(movieId: self.movie.id)
                    }
                }
                self.state = .success(movie, photos, videos, casts, favorite: favorite, watchLater: isWatchLater)
            } catch {
                log(error)
                self.state = .failure(error)
            }
        }
    }
}
