//
//  AuthorizationType.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 12.04.2026.
//

import Foundation

nonisolated public enum AuthorizationType: Sendable {
    case bearer(String)

    var value: String {
        switch self {
        case .bearer(let value): return "Bearer \(value)"
        }
    }
}
