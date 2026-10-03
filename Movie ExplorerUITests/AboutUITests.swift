//
//  AboutUITests.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

final class AboutUITests: MovieExplorerUITestCase {

    @MainActor
    func testAboutShowsTitleAndTMDBLink() {
        let app = launchApp()

        app.open(.about)

        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: defaultTimeout))
        let link = app.element(A11y.aboutLink)
        XCTAssertTrue(link.exists)
        XCTAssertEqual(link.label, "TMDB Developer Documentation")
    }
}
