//
//  AccessTokenResponse.swift
//  Movie Explorer
//

import Foundation

nonisolated struct AccessTokenRequest: Encodable {
    let requestToken: String

    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}

nonisolated struct AccessTokenResponse: Decodable {
    let success: Bool
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case success
        case accessToken = "access_token"
    }
}
