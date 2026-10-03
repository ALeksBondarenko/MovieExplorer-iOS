//
//  RequestTokenResponse.swift
//  Movie Explorer
//

import Foundation

nonisolated struct RequestTokenRequest: Encodable {
    let redirectTo: String

    enum CodingKeys: String, CodingKey {
        case redirectTo = "redirect_to"
    }
}

nonisolated struct RequestTokenResponse: Decodable {
    let success: Bool
    let requestToken: String

    enum CodingKeys: String, CodingKey {
        case success
        case requestToken = "request_token"
    }
}
