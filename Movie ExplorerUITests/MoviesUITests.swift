//
//  MoviesUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class MoviesUITests: MovieExplorerUITestCase {

    @MainActor
    func testFirstPageIsShown() {
        let app = launchApp()

        let movie = app.element(A11y.movie(Fixtures.firstPopularMovie.id))
        XCTAssertTrue(movie.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(movie.label.contains(Fixtures.firstPopularMovie.title), "Poster must show the movie title")
    }

    @MainActor
    func testScrollingLoadsNextPage() {
        let app = launchApp()
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))

        let movieFromSecondPage = app.element(A11y.movie(Fixtures.firstMovieOfSecondPage))
        XCTAssertTrue(app.swipeUp(toReveal: movieFromSecondPage, maxSwipes: 25), "Second page was not loaded")
    }

    @MainActor
    func testFirstPageErrorShowsRetryAndRetryLoadsMovies() {
        let app = launchApp(scenario: .moviesFirstPageError)

        let retry = app.element(A11y.errorRetryButton)
        XCTAssertTrue(retry.waitForExistence(timeout: defaultTimeout), "Error view with Retry is not shown")

        retry.tap()

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(retry.exists)
    }

    @MainActor
    func testNextPageErrorShowsAlertAndRetryLoadsNextPage() {
        let app = launchApp(scenario: .moviesNextPageError)
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))

        let alert = app.alerts.firstMatch
        for _ in 0..<25 where !alert.exists {
            app.swipeUp()
        }
        XCTAssertTrue(alert.waitForExistence(timeout: defaultTimeout), "Next page error alert is not shown")

        // Already loaded movies stay on screen behind the alert.
        alert.buttons["Retry"].tap()
        XCTAssertTrue(alert.waitUntilHidden())

        let movieFromSecondPage = app.element(A11y.movie(Fixtures.firstMovieOfSecondPage))
        XCTAssertTrue(app.swipeUp(toReveal: movieFromSecondPage, maxSwipes: 10), "Second page was not loaded after retry")
    }

    @MainActor
    func testOpeningMovieShowsDetails() {
        let app = launchApp()

        app.openMovie(Fixtures.firstPopularMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstPopularMovie.title)
    }
}
