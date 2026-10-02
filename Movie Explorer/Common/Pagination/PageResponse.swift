//
//  PageResponse.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import Foundation

protocol PageResponse {
    associatedtype Item

    var page: Int? { get }
    var results: [Item] { get }
    var totalPages: Int { get }
}
