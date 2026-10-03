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
        PaginatedView(paginator: viewModel.movies) { _ in
            MoviesGridView(paginator: viewModel.movies)
        }
        .navigationTitle(viewModel.title)
        .toolbarBackground(.ultraThickMaterial, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
