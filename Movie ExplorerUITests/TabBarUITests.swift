//
//  TabBarUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class TabBarUITests: MovieExplorerUITestCase {

    @MainActor
    func testAllTabsAreShown() {
        let app = launchApp()

        for tab in [AppTab.movies, .watchList, .favorite, .about, .search] {
            XCTAssertTrue(app.tabButton(tab).waitForExistence(timeout: defaultTimeout), "Tab \(tab.rawValue) is missing")
        }
    }

    @MainActor
    func testMoviesTabIsOpenOnLaunch() {
        let app = launchApp()

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))
    }

    /// Each tab opens its own root screen.
    /// (Switching tabs from a pushed screen is impossible: the tab bar is hidden there.)
    @MainActor
    func testEachTabOpensItsRootScreen() {
        let app = launchApp(loggedIn: false)

        app.open(.watchList)
        XCTAssertTrue(app.element(A11y.loginButton).waitForExistence(timeout: defaultTimeout), "Watch List root is not shown")

        app.open(.favorite)
        XCTAssertTrue(app.element(A11y.loginButton).waitForExistence(timeout: defaultTimeout), "Favorites root is not shown")

        app.open(.about)
        XCTAssertTrue(app.element(A11y.aboutLink).waitForExistence(timeout: defaultTimeout), "About root is not shown")

        app.open(.search)
        XCTAssertTrue(app.element(A11y.searchField).waitForExistence(timeout: defaultTimeout), "Search root is not shown")

        app.open(.movies)
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout), "Movies root is not shown")
    }

    @MainActor
    func testTabStaysOnRootAfterGoingBackAndSwitchingTabs() {
        let app = launchApp()
        app.openMovie(Fixtures.firstPopularMovie.id)

        app.goBack()
        XCTAssertTrue(app.tabBar.waitUntilHittable())

        app.open(.about)
        app.open(.movies)

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstPopularMovie.id)).waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(app.element(A11y.detailsTitle).exists, "Movies tab must stay on its root after going back")
    }
}
