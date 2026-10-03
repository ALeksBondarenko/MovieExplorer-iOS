//
//  SearchUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class SearchUITests: MovieExplorerUITestCase {

    /// Search waits ~0.4 s after the last keystroke before requesting results.
    private let searchTimeout: TimeInterval = 5

    @MainActor
    private func search(_ query: String, in app: XCUIApplication) {
        app.open(.search)
        let field = app.element(A11y.searchField)
        XCTAssertTrue(field.waitForExistence(timeout: defaultTimeout))
        field.tap()
        field.typeText(query)
    }

    @MainActor
    func testIdleStateAsksToStartTyping() {
        let app = launchApp()

        app.open(.search)

        XCTAssertTrue(app.staticTexts["Start typing"].waitForExistence(timeout: defaultTimeout))
    }

    @MainActor
    func testQueryShowsMoviesPeopleAndSuggestions() {
        let app = launchApp()

        search(Fixtures.searchQuery, in: app)

        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstSearchMovie.id)).waitForExistence(timeout: searchTimeout))
        XCTAssertTrue(app.element(A11y.person(Fixtures.searchPerson.id)).exists)
        XCTAssertTrue(app.element(A11y.suggestion(Fixtures.searchKeyword.id)).exists)
    }

    @MainActor
    func testQueryWithoutResultsShowsNoResults() {
        let app = launchApp()

        search(Fixtures.emptySearchQuery, in: app)

        XCTAssertTrue(app.staticTexts["No result"].waitForExistence(timeout: searchTimeout))
    }

    @MainActor
    func testTooShortQueryDoesNotSearch() {
        let app = launchApp()

        search("to", in: app)

        XCTAssertTrue(app.staticTexts["Start typing"].exists)
        XCTAssertFalse(app.element(A11y.movie(Fixtures.firstSearchMovie.id)).waitForExistence(timeout: 1.5))
    }

    @MainActor
    func testSuggestionReplacesQuery() {
        let app = launchApp()
        search(Fixtures.searchQuery, in: app)

        let suggestion = app.element(A11y.suggestion(Fixtures.searchKeyword.id))
        XCTAssertTrue(suggestion.waitForExistence(timeout: searchTimeout))
        suggestion.tap()

        let field = app.element(A11y.searchField)
        XCTAssertTrue(field.wait(until: "value == '\(Fixtures.searchKeyword.name)'"), "Suggestion did not replace the query")
    }

    @MainActor
    func testFoundMovieOpensDetails() {
        let app = launchApp()
        search(Fixtures.searchQuery, in: app)
        XCTAssertTrue(app.element(A11y.movie(Fixtures.firstSearchMovie.id)).waitForExistence(timeout: searchTimeout))

        app.openMovie(Fixtures.firstSearchMovie.id)

        XCTAssertEqual(app.detailsTitle(), Fixtures.firstSearchMovie.title)
        XCTAssertTrue(app.tabBar.waitUntilHidden())
    }

    @MainActor
    func testFoundPersonOpensPerson() {
        let app = launchApp()
        search(Fixtures.searchQuery, in: app)

        let person = app.element(A11y.person(Fixtures.searchPerson.id))
        XCTAssertTrue(person.waitForExistence(timeout: searchTimeout))
        person.tap()

        let name = app.element(A11y.personName)
        XCTAssertTrue(name.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(name.label, Fixtures.searchPerson.name)
    }
}
