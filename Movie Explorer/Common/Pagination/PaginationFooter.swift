//
//  PaginationFooter.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI


struct PaginationFooter<Item: Identifiable>: View {
    let paginator: Paginator<Item>

    var body: some View {
        if paginator.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}
