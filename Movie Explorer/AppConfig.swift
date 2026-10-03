//
//  Enviroment.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 24.01.2026.
//

import Foundation

nonisolated public enum AppConfig {
    enum Keys {
        static let apiKey = "API_KEY"
    }

    static let apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: Keys.apiKey) as? String else {
            fatalError("API key not found in plist file")
        }
        return apiKey
    }()
}
