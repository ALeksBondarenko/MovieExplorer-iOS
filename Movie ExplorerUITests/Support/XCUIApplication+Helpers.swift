//
//  XCUIApplication+Helpers.swift
//  Movie ExplorerUITests
//
//  Created by Александр Бондаренко on 04.10.2026.
//

import XCTest

let defaultTimeout: TimeInterval = 5

@MainActor
extension XCUIApplication {

    /// Any element with the given accessibility identifier.
    func element(_ identifier: String) -> XCUIElement {
        descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    var tabBar: XCUIElement {
        tabBars.firstMatch
    }

    func tabButton(_ tab: AppTab) -> XCUIElement {
        tabBars.buttons[tab.rawValue].firstMatch
    }

    func open(_ tab: AppTab, file: StaticString = #filePath, line: UInt = #line) {
        let button = tabButton(tab)
        XCTAssertTrue(button.waitForExistence(timeout: defaultTimeout), "Tab \(tab.rawValue) not found", file: file, line: line)
        button.tap()
    }

    /// Taps the first button of the navigation bar, which is the back button on pushed screens.
    func goBack() {
        navigationBars.buttons.element(boundBy: 0).tap()
    }

    /// Swipes up until the element is on screen and can be tapped.
    @discardableResult
    func swipeUp(toReveal element: XCUIElement, maxSwipes: Int = 15) -> Bool {
        for _ in 0..<maxSwipes {
            if element.exists && element.isHittable {
                return true
            }
            swipeUp()
        }
        return element.exists && element.isHittable
    }

    /// Waits for the details screen and returns its title text.
    func detailsTitle(file: StaticString = #filePath, line: UInt = #line) -> String {
        let title = element(A11y.detailsTitle)
        XCTAssertTrue(title.waitForExistence(timeout: defaultTimeout), "Details screen not shown", file: file, line: line)
        return title.label
    }

    /// Opens a movie from the current screen and waits for its details.
    func openMovie(_ id: Int, file: StaticString = #filePath, line: UInt = #line) {
        let movie = element(A11y.movie(id))
        XCTAssertTrue(movie.waitForExistence(timeout: defaultTimeout), "Movie \(id) not found", file: file, line: line)
        XCTAssertTrue(swipeUp(toReveal: movie), "Movie \(id) is not reachable", file: file, line: line)
        movie.tap()
        XCTAssertTrue(element(A11y.detailsTitle).waitForExistence(timeout: defaultTimeout), "Details of movie \(id) not shown", file: file, line: line)
    }
}

@MainActor
extension XCUIElement {

    /// Waits until the element matches the predicate, e.g. `"selected == true"`.
    @discardableResult
    func wait(until format: String, timeout: TimeInterval = defaultTimeout) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: format), object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    @discardableResult
    func waitUntilHittable(timeout: TimeInterval = defaultTimeout) -> Bool {
        wait(until: "exists == true AND hittable == true", timeout: timeout)
    }

    /// True once the element is gone or covered (e.g. the hidden tab bar).
    @discardableResult
    func waitUntilHidden(timeout: TimeInterval = defaultTimeout) -> Bool {
        wait(until: "exists == false OR hittable == false", timeout: timeout)
    }
}
