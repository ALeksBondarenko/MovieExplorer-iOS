//
//  PersonUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class PersonUITests: MovieExplorerUITestCase {

    @MainActor
    private func openFirstCastMember(in app: XCUIApplication) {
        app.openMovie(Fixtures.firstPopularMovie.id)
        let actor = app.element(A11y.person(Fixtures.firstCast.id))
        XCTAssertTrue(app.swipeUp(toReveal: actor), "Cast is not shown")
        actor.tap()
        XCTAssertTrue(app.element(A11y.personName).waitForExistence(timeout: defaultTimeout))
    }

    @MainActor
    func testPersonShowsNameAndMovies() {
        let app = launchApp()
        openFirstCastMember(in: app)

        XCTAssertEqual(app.element(A11y.personName).label, Fixtures.firstCast.name)
        XCTAssertTrue(app.staticTexts["Biography"].exists)

        let movie = app.element(A11y.movie(Fixtures.firstPersonMovie.id))
        XCTAssertTrue(app.swipeUp(toReveal: movie), "Movies of the person are not shown")
    }

    @MainActor
    func testTabBarIsHiddenOnPerson() {
        let app = launchApp()
        openFirstCastMember(in: app)

        XCTAssertTrue(app.tabBar.waitUntilHidden())
    }

    @MainActor
    func testMovieOfPersonOpensDetails() {
        let app = launchApp()
        openFirstCastMember(in: app)

        app.openMovie(Fixtures.firstPersonMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstPersonMovie.title)
    }

    @MainActor
    func testBackReturnsToMovieDetails() {
        let app = launchApp()
        openFirstCastMember(in: app)

        app.goBack()

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstPopularMovie.title)
    }
}
