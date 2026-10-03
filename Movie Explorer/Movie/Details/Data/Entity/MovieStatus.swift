//
//  MovieStatus.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 31.12.2025.
//

import Foundation

nonisolated struct MovieStatus : Equatable, Codable {
    let id: Int
    let favorite: Bool
    let watchlist: Bool
}
