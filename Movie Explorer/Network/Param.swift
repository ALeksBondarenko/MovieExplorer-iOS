//
//  Param.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 12.04.2026.
//

import Foundation

nonisolated struct Param: Sendable {
    let name: String
    let value: String

    init(name: String, value: CustomStringConvertible) {
        self.name = name
        self.value = value.description
    }
}
