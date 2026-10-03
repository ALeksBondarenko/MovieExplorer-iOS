//
//  MovieDetailsUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class MovieDetailsUITests: MovieExplorerUITestCase {

    // MARK: - Navigation

    @MainActor
    func testTabBarIsHiddenOnDetailsAndShownAfterBack() {
        let app = launchApp()
        XCTAssertTrue(app.tabBar.waitUntilHittable())

        app.openMovie(Fixtures.firstPopularMovie.id)
        XCTAssertTrue(app.tabBar.waitUntilHidden(), "Tab bar must be hidden on the details screen")

        app.goBack()
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(app.tabBar.waitUntilHittable(), "Tab bar must come back on the root screen")
    }

    @MainActor
    func testBackReturnsToTheList() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        app.goBack()

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(app.element(A11y.detailsTitle).exists)
    }

    @MainActor
    func testGenreOpensMoviesOfTheGenre() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        let genre = app.element(A11y.genre(Fixtures.genre.id))
        XCTAssertTrue(genre.waitForExistence(timeout: defaultTimeout))
        genre.tap()

        XCTAssertTrue(app.navigationBars[Fixtures.genre.name].waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(app.tabBar.waitUntilHidden())

        app.openMovie(Fixtures.firstGenreMovie.id)
        XCTAssertEqual(app.detailsTitle(), Fixtures.firstGenreMovie.title)
    }

    @MainActor
    func testCastOpensPerson() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        let actor = app.element(A11y.person(Fixtures.firstCast.id))
        XCTAssertTrue(app.swipeUp(toReveal: actor), "Cast is not shown")
        actor.tap()

        let name = app.element(A11y.personName)
        XCTAssertTrue(name.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(name.label, Fixtures.firstCast.name)
    }

    @MainActor
    func testSimilarMovieOpensItsDetails() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        app.openMovie(Fixtures.firstSimilarMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstSimilarMovie.title)
    }

    @MainActor
    func testTrailerIsShownAsPreview() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        let trailer = app.element(A11y.trailer(Fixtures.trailerKey))
        XCTAssertTrue(app.swipeUp(toReveal: trailer), "Trailer preview is not shown")
        XCTAssertEqual(trailer.label, "Play trailer")
    }

    // MARK: - Favorite & watch later

    @MainActor
    func testToggleFavorite() {
        let app = launchApp(loggedIn: true)
        app.openMovie(Fixtures.firstPopularMovie.id)

        let notFavorite = app.element(A11y.favoriteButton(on: false))
        XCTAssertTrue(notFavorite.waitForExistence(timeout: defaultTimeout))

        notFavorite.tap()
        let favorite = app.element(A11y.favoriteButton(on: true))
        XCTAssertTrue(favorite.waitForExistence(timeout: defaultTimeout), "Movie was not added to favorites")

        favorite.tap()
        XCTAssertTrue(app.element(A11y.favoriteButton(on: false)).waitForExistence(timeout: defaultTimeout), "Movie was not removed from favorites")
    }

    @MainActor
    func testToggleWatchLater() {
        let app = launchApp(loggedIn: true)
        app.openMovie(Fixtures.firstPopularMovie.id)

        let notInWatchList = app.element(A11y.watchLaterButton(on: false))
        XCTAssertTrue(notInWatchList.waitForExistence(timeout: defaultTimeout))

        notInWatchList.tap()
        let inWatchList = app.element(A11y.watchLaterButton(on: true))
        XCTAssertTrue(inWatchList.waitForExistence(timeout: defaultTimeout), "Movie was not added to watch later")

        inWatchList.tap()
        XCTAssertTrue(app.element(A11y.watchLaterButton(on: false)).waitForExistence(timeout: defaultTimeout), "Movie was not removed from watch later")
    }

    @MainActor
    func testFavoriteWhenLoggedOutLogsInAndMarksMovie() {
        let app = launchApp(loggedIn: false)
        app.openMovie(Fixtures.firstPopularMovie.id)

        let notFavorite = app.element(A11y.favoriteButton(on: false))
        XCTAssertTrue(notFavorite.waitForExistence(timeout: defaultTimeout))
        notFavorite.tap()
        XCTAssertTrue(
            app.element(A11y.favoriteButton(on: true)).waitForExistence(timeout: defaultTimeout),
            "Login and retry did not mark the movie as favorite"
        )

        // The session is shared: the Favorites tab no longer asks to log in.
        app.goBack()
        app.open(.favorite)
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstFavoriteMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(app.element(A11y.loginButton).exists)
    }
}
