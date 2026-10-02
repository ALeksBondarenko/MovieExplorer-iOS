//
//  GenreByMoviesScreen.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 07.03.2026.
//

import SwiftUI
import Swinject

struct GenreByMoviesScreen: View {

    @StateObject var viewModel: GenreByMoviesViewModel
    
    init(viewModel: @autoclosure @escaping () -> GenreByMoviesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                FullScreenProgressView()
            case .content(let movies, let error):
                MoviesView(
                    movies: movies,
                    refresh: viewModel.refreshMovies,
                    loadNextPage: viewModel.fetchMoreMovies
                ).alerError(
                    error: error,
                    onRetry: viewModel.refreshMovies,
                    onCancel: viewModel.clearError
                )
            }
        }
        .navigationTitle(viewModel.title)
        .toolbarBackground(.ultraThickMaterial, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .onAppear {
            viewModel.fetchMovies()
        }
    }

    @ViewBuilder
    func MoviesView(
        movies: [Movie],
        refresh: @escaping @Sendable () -> Void,
        loadNextPage: @escaping @Sendable () -> Void
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(movies, id: \.id) { movie in
                    NavigationLink(value: Route.details(movie)) {
                        PosterView(movie: movie)
                            .onAppear {
                                if movie == movies.last {
                                    loadNextPage()
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }.refreshable {
            refresh()
        }
    }
}

#Preview {
    GenreByMoviesScreen(
        viewModel: DIContainer.shared.container.resolve(
            GenreByMoviesViewModel.self,
            argument: Genres(id: 16, name: "Мультфильмы")
        )!
    )
}
