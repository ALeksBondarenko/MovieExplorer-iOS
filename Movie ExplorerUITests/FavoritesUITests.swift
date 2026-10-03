//
//  FavoritesUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class FavoritesUITests: MovieExplorerUITestCase {

    @MainActor
    func testLoggedOutShowsLoginPrompt() {
        let app = launchApp(loggedIn: false)

        app.open(.favorite)

        XCTAssertTrue(app.element(A11y.loginButton).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(app.element(A11y.movie(Fixtures.firstFavoriteMovie.id)).exists)
    }

    @MainActor
    func testLoginShowsFavoriteMovies() {
        let app = launchApp(loggedIn: false)
        app.open(.favorite)

        let login = app.element(A11y.loginButton)
        XCTAssertTrue(login.waitForExistence(timeout: defaultTimeout))
        login.tap()

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstFavoriteMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(login.exists)
    }

    @MainActor
    func testLoggedInShowsFavoriteMovies() {
        let app = launchApp(loggedIn: true)

        app.open(.favorite)

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstFavoriteMovie.id)).waitForExistence(timeout: defaultTimeout))
    }

    @MainActor
    func testEmptyFavoritesShowEmptyState() {
        let app = launchApp(loggedIn: true, scenario: .emptyLists)

        app.open(.favorite)

        let empty = app.element(A11y.emptyState)
        XCTAssertTrue(empty.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(empty.label, "No favorite movies yet")
    }

    @MainActor
    func testFavoriteMovieOpensDetails() {
        let app = launchApp(loggedIn: true)
        app.open(.favorite)

        app.openMovie(Fixtures.firstFavoriteMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstFavoriteMovie.title)
        XCTAssertTrue(app.tabBar.waitUntilHidden())
    }
}
