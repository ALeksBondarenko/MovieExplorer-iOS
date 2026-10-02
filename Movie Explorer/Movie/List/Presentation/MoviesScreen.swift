//
//  MainScreen.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 29.12.2025.
//

import SwiftUI

struct MoviesScreen: View {

    @StateObject var viewModel: MoviesViewModel
    
    init(viewModel: @autoclosure @escaping () -> MoviesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle,.loading:
                FullScreenProgressView()
            case .content(let movies, let error):
                MoviesView(
                    movies: movies,
                    refresh: viewModel.refreshMovies,
                    loadNextPage: viewModel.fetchMoreMovies
                ).alerError(
                    error: error,
                    onRetry: viewModel.reloadLastPage,
                    onCancel: viewModel.clearError
                )
            }
        }.onAppear {
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
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
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
    MoviesScreen(viewModel: MoviesViewModel(
        repository: MoviesRepositoryImpl(
            service: MoviesService(
                networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
                        urlSession: .shared
                    )
            )
        )
    ))
    .preferredColorScheme(ColorScheme.dark)
}


#Preview {
    MoviesScreen(viewModel: MoviesViewModel(
        repository: MoviesRepositoryImpl(
            service: MoviesService(
                networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
                        urlSession: .shared
                    )
            )
        )
    ))
}
