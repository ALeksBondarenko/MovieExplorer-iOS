//
//  AboutView.swift
//  Movie Explorer
//

import SwiftUI

struct AboutView: View {

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("aboutDisclaimer")
                    .font(.body)

                Link("aboutTMDBLinkTitle", destination: URL(string: "https://www.themoviedb.org")!)
                    .font(.body)

                Spacer()
            }
            .padding()
            .navigationTitle("aboutTitle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AboutView()
}
