//
//  Route.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import Foundation

enum Route: Hashable {
    case details(Movie)
    case person(Cast)
    case genre(Genres)
}
