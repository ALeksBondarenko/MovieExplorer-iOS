//
//  AuthSession.swift
//  Movie Explorer
//

import Foundation

nonisolated struct AuthSession: Equatable, Codable {
    let accessToken: String
    let accountId: Int
}
