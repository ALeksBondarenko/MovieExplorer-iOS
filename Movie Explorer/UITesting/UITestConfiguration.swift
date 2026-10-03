//
//  UITestConfiguration.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 04.10.2026.
//

#if DEBUG
import Foundation

/// Launch options passed by the UI test target.
///
/// UI tests launch the app with `-uiTesting`; the app then replaces the network-backed
/// repositories with in-memory stubs, so tests don't depend on TMDB, the API key or the network.
/// Compiled into Debug builds only.
enum UITestConfiguration {

    static let launchArgument = "-uiTesting"
    static let loggedInKey = "UITEST_LOGGED_IN"
    static let scenarioKey = "UITEST_SCENARIO"

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    static var isLoggedIn: Bool {
        ProcessInfo.processInfo.environment[loggedInKey] == "1"
    }

    static var scenario: UITestScenario {
        ProcessInfo.processInfo.environment[scenarioKey].flatMap(UITestScenario.init(rawValue:)) ?? .standard
    }
}

/// Keep raw values in sync with `UITestScenario` in the UI test target.
enum UITestScenario: String {
    /// Every request succeeds.
    case standard
    /// The first request for the first page of movies fails, the retry succeeds.
    case moviesFirstPageError
    /// The first request for the second page of movies fails, the retry succeeds.
    case moviesNextPageError
    /// Favorites and watch list are empty.
    case emptyLists
}
#endif
