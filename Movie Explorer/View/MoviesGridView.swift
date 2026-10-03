//
//  MoviesGridView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI

/// Two-column poster grid backed by a `Paginator`.
struct MoviesGridView: View {
    let paginator: Paginator<Movie>
    var spacing: CGFloat? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: spacing) {
                ForEach(paginator.items) { movie in
                    NavigationLink(value: Route.details(movie)) {
                        PosterView(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("movie.\(movie.id)")
                    .paginated(movie, in: paginator)
                }
            }
            .padding(.horizontal)

            PaginationFooter(paginator: paginator)
        }
    }
}
