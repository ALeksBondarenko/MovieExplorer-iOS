//
//  MoviesRowView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI

/// Horizontal poster row backed by a `Paginator`.
struct MoviesRowView: View {
    let paginator: Paginator<Movie>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(paginator.items) { movie in
                    NavigationLink(value: Route.details(movie)) {
                        PosterView(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("movie.\(movie.id)")
                    .paginated(movie, in: paginator)
                }

                PaginationFooter(paginator: paginator)
            }
            .padding(.horizontal, 15)
        }
    }
}
