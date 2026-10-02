//
//  PaginatedView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 02.10.2026.
//

import SwiftUI

struct PaginatedView<Item: Identifiable, Content: View, Empty: View>: View {
    let paginator: Paginator<Item>
    var onCancel: () -> Void = {}
    @ViewBuilder let content: ([Item]) -> Content
    @ViewBuilder let empty: () -> Empty

    var body: some View {
        Group {
            switch paginator.phase {
            case .idle, .loading:
                FullScreenProgressView()
            case .empty:
                empty()
            case .failed(let error):
                ErrorView(
                    error: error,
                    onRetry: { paginator.retry() },
                    onCancel: onCancel
                )
            case .loaded:
                content(paginator.items)
                    .alerError(
                        error: paginator.error,
                        onRetry: { paginator.retry() },
                        onCancel: { paginator.clearError() }
                    )
            }
        }
        .onAppear {
            paginator.loadIfNeeded()
        }
        .refreshable {
            await paginator.refresh()
        }
    }
}

extension PaginatedView where Empty == EmptyView {
    init(
        paginator: Paginator<Item>,
        onCancel: @escaping () -> Void = {},
        @ViewBuilder content: @escaping ([Item]) -> Content
    ) {
        self.init(paginator: paginator, onCancel: onCancel, content: content, empty: { EmptyView() })
    }
}
