//
//  PersonsPage.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 03.08.2026.
//

import Foundation

struct PersonsPage: Equatable, Codable {
    let page: Int?
    let results: [Cast]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}
