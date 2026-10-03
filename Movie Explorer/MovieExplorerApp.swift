//
//  MovieExplorerApp.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 24.01.2026.
//

import SwiftUI
import UIKit
import SwiftData
import Swinject
import SwinjectAutoregistration

@main
struct MovieExplorerApp: App {

    init() {
        #if DEBUG
        if UITestConfiguration.isEnabled {
            // Faster and more stable UI tests: no push/pop and alert animations.
            UIView.setAnimationsEnabled(false)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
