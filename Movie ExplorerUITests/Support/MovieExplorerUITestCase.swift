//
//  MovieExplorerUITestCase.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

/// Base class for UI tests.
///
/// Launches the app in UI test mode: repositories are replaced with in-memory stubs
/// (see `Movie Explorer/UITesting`), so tests don't need network access or a TMDB key.
/// The UI language is forced to English so tab titles and system texts are predictable.
class MovieExplorerUITestCase: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    @discardableResult
    func launchApp(loggedIn: Bool = false, scenario: UITestScenario = .standard) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-uiTesting",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launchEnvironment["UITEST_LOGGED_IN"] = loggedIn ? "1" : "0"
        app.launchEnvironment["UITEST_SCENARIO"] = scenario.rawValue
        app.launch()
        return app
    }
}

/// Keep raw values in sync with `UITestScenario` in the app target.
enum UITestScenario: String {
    case standard
    case moviesFirstPageError
    case moviesNextPageError
    case emptyLists
}
