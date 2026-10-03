//
//  GenreByMoviesViewModel.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 07.03.2026.
//

import Foundation
import Combine

@MainActor
final class GenreByMoviesViewModel: ObservableObject {

    let title: String
    let movies: Paginator<Movie>

    init(repository: MoviesRepository, genre: Genres) {
        title = genre.name.capitalizedFirst
        movies = Paginator<Movie> { [repository] page in
            try await repository.fetchMovies(page: page, genre: genre)
        }
    }
}

private extension String {
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
}
