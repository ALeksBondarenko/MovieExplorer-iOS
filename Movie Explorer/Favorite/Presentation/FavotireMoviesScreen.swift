//
//  FavotireMoviesView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 30.12.2025.
//

import SwiftUI

struct FavotireMoviesScreen: View {
    
    @StateObject var viewModel: FavotireMoviesViewModel
    
    init(viewModel: @autoclosure @escaping () -> FavotireMoviesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                PaginatedView(paginator: viewModel.movies) { _ in
                    MoviesGridView(paginator: viewModel.movies, spacing: 12)
                } empty: {
                    EmptyMoviesView()
                }
            } else {
                LoginPromptView(login: viewModel.login)
            }
        }
        .onAppear {
            viewModel.updateAuthentication()
        }
    }

    @ViewBuilder
    func EmptyMoviesView() -> some View {
        ZStack(alignment: .center) {
            Text("emptyFavorites")
                .font(.body)
                .accessibilityIdentifier("emptyState")
        }
    }

    @ViewBuilder
    func LoginPromptView(login: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text("loginPromptMessage")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                login()
            } label: {
                Text("loginPromptButton")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color("PrimaryButtonColor"))
                    .cornerRadius(12)
            }
            .accessibilityIdentifier("loginPrompt.button")
        }
        .padding()
    }
}

#Preview {
    FavotireMoviesScreen(viewModel: FavotireMoviesViewModel(
        repository: FavoriteRepositoryImpl(
            service: FavoriteService(
                networkClient: NetworkClient(
                    connectionErrorMapper: ConnectionErrorMapper(),
                    sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
                    urlSession: .shared
                )
            ),
            authRepository: AuthRepositoryImpl(
                service: AuthService(
                    networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
                    urlSession: .shared
                    )
                ),
                sessionStore: KeychainSessionStore(),
                webAuthPresenter: WebAuthPresenter()
            )
        ),
        authRepository: AuthRepositoryImpl(
            service: AuthService(
                networkClient: NetworkClient(
                    connectionErrorMapper: ConnectionErrorMapper(),
                    sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
                    urlSession: .shared
                )
            ),
            sessionStore: KeychainSessionStore(),
            webAuthPresenter: WebAuthPresenter()
        )
    ))
}
