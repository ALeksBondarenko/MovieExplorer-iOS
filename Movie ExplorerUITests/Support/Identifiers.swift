//
//  Identifiers.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import Foundation

/// Accessibility identifiers set in the app.
enum A11y {
    static func movie(_ id: Int) -> String { "movie.\(id)" }
    static func person(_ id: Int) -> String { "person.\(id)" }
    static func genre(_ id: Int) -> String { "genre.\(id)" }
    static func suggestion(_ id: Int) -> String { "suggestion.\(id)" }
    static func trailer(_ key: String) -> String { "trailer.\(key)" }

    static let detailsTitle = "details.title"
    /// The toolbar buttons carry their state in the identifier.
    static func favoriteButton(on: Bool) -> String { "details.favoriteButton.\(on ? "on" : "off")" }
    static func watchLaterButton(on: Bool) -> String { "details.watchLaterButton.\(on ? "on" : "off")" }
    static let personName = "person.name"
    static let searchField = "search.field"
    static let loginButton = "loginPrompt.button"
    static let emptyState = "emptyState"
    static let errorRetryButton = "error.retryButton"
    static let aboutLink = "about.tmdbLink"
}

/// Tab titles in English (the tests force the English UI).
enum AppTab: String {
    case movies = "Movies"
    case watchList = "Watch List"
    case favorite = "Favorite"
    case about = "About"
    case search = "Search"
}

/// Stub data served by the app in UI test mode.
/// Keep in sync with `UITestFixtures` in the app target.
enum Fixtures {
    static let firstPopularMovie = (id: 1, title: "Movie 1")
    static let firstMovieOfSecondPage = 21

    static let genre = (id: 28, name: "Action")
    static let firstGenreMovie = (id: 101, title: "Action Movie 1")

    static let firstSimilarMovie = (id: 201, title: "Similar 1")
    static let firstPersonMovie = (id: 301, title: "Filmography 1")
    static let firstSearchMovie = (id: 401, title: "Found Movie 1")
    static let firstFavoriteMovie = (id: 801, title: "Favorite Movie 1")
    static let firstWatchListMovie = (id: 901, title: "Watch Movie 1")

    static let firstCast = (id: 501, name: "Actor One")
    static let searchPerson = (id: 601, name: "Found Person")
    static let searchKeyword = (id: 701, name: "toy story")

    static let trailerKey = "uitest123"

    static let searchQuery = "toy"
    static let emptySearchQuery = "nothing"
}
