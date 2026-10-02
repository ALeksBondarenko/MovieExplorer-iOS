//
//  View+Pagination.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI

extension View {

    func paginated<Item: Identifiable>(_ item: Item, in paginator: Paginator<Item>) -> some View {
        onAppear {
            paginator.loadMoreIfNeeded(after: item)
        }
    }
}
