//
//  File.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 06.12.2025.
//

import Foundation
import Combine

@MainActor
final class MoviesViewModel: ObservableObject {

    let movies: Paginator<Movie>

    init(repository: MoviesRepository) {
        movies = Paginator<Movie> { [repository] page in
            try await repository.fetchMovies(page: page)
        }
    }
}
