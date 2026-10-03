//
//  TrailerResponse.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 10.12.2025.
//

import Foundation

nonisolated final class VideosResponse: Codable, Sendable {
    let results: [Video]

    init(results: [Video]) {
        self.results = results
    }
}


