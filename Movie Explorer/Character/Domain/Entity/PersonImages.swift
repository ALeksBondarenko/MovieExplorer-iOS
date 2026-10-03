//
//  PersonImages.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 10.12.2025.
//

import Foundation

nonisolated struct PersonImages: Codable {
    let profiles: [PersonImage]
}


nonisolated struct PersonImage: Codable, Equatable {
    let filePath: String
    
    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}
