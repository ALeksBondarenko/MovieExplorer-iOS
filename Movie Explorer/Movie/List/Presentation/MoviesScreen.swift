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
        PaginatedView(paginator: viewModel.movies) { _ in
            MoviesGridView(paginator: viewModel.movies)
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
