//
//  FavotireMoviesView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 30.12.2025.
//

import SwiftUI
import Swinject

struct WatchListScreen: View {
    
    @StateObject var viewModel: WatchListViewModel
    
    init(viewModel: @autoclosure @escaping () -> WatchListViewModel) {
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
            Text("emptyWatchList")
                .font(.body)
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
        }
        .padding()
    }
}

#Preview {
    WatchListScreen(viewModel: DIContainer.shared.container.resolve(WatchListViewModel.self)!)
}
