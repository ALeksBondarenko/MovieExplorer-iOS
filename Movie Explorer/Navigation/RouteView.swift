//
//  RouteView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI
import Swinject

private struct RouteView: View {
    let route: Route
       private var di: Container { DIContainer.shared.container }

       var body: some View {
           switch route {
           case .details(let movie):
               MovieDetailsScreen(viewModel: di.resolve(MovieDetailsViewModel.self, argument: movie)!)
           case .person(let cast):
               PersonScreen(viewModel: di.resolve(PersonViewModel.self, argument: cast)!)
           case .genre(let genre):
               GenreByMoviesScreen(viewModel: di.resolve(GenreByMoviesViewModel.self, argument: genre)!)
        }
    }
}

extension View {
    func withAppRoutes() -> some View {
        navigationDestination(for: Route.self) { RouteView(route: $0) }
    }
}
