//
//  WatchListUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class WatchListUITests: MovieExplorerUITestCase {

    @MainActor
    func testLoggedOutShowsLoginPrompt() {
        let app = launchApp(loggedIn: false)

        app.open(.watchList)

        XCTAssertTrue(app.element(A11y.loginButton).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(app.element(A11y.movie(Fixtures.firstWatchListMovie.id)).exists)
    }

    @MainActor
    func testLoginShowsWatchList() {
        let app = launchApp(loggedIn: false)
        app.open(.watchList)

        let login = app.element(A11y.loginButton)
        XCTAssertTrue(login.waitForExistence(timeout: defaultTimeout))
        login.tap()

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstWatchListMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(login.exists)
    }

    @MainActor
    func testLoggedInShowsWatchList() {
        let app = launchApp(loggedIn: true)

        app.open(.watchList)

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstWatchListMovie.id)).waitForExistence(timeout: defaultTimeout))
    }

    @MainActor
    func testEmptyWatchListShowsEmptyState() {
        let app = launchApp(loggedIn: true, scenario: .emptyLists)

        app.open(.watchList)

        let empty = app.element(A11y.emptyState)
        XCTAssertTrue(empty.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(empty.label, "No watch list yet")
    }

    @MainActor
    func testWatchListMovieOpensDetails() {
        let app = launchApp(loggedIn: true)
        app.open(.watchList)

        app.openMovie(Fixtures.firstWatchListMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstWatchListMovie.title)
        XCTAssertTrue(app.tabBar.waitUntilHidden())
    }
}
