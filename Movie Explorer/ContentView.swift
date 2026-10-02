//
//  ContentView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 06.12.2025.
//

import SwiftUI
import SwiftData
import Swinject

struct ContentView: View {
    private var di: Container { DIContainer.shared.container }
    
    var body: some View {
        TabView {
            Tab("movies_tab_name", systemImage: "movieclapper") {
                NavigationStack {
                    MoviesScreen(viewModel: di.resolve(MoviesViewModel.self)!)
                        .withAppRoutes()
                }
            }
            
            Tab("watchlist_tab_name", systemImage: "bookmark") {
                NavigationStack {
                    WatchListScreen(viewModel: di.resolve(WatchListViewModel.self)!)
                        .withAppRoutes()
                }
            }
            
            Tab("favorite_tab_name", systemImage: "heart") {
                NavigationStack {
                    FavotireMoviesScreen(viewModel: di.resolve(FavotireMoviesViewModel.self)!)
                        .withAppRoutes()
                }
            }
            
            Tab("aboutButtonAccessibilityLabel", systemImage: "info.circle") {
                AboutView()
            }
            
            Tab("search_tab_name", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    SearchScreen(viewModel: di.resolve(SearchViewModel.self)!)
                        .withAppRoutes()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
