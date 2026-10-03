//
//  TrailerView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 03.10.2026.
//

import SwiftUI

struct TrailerView: View {

    let video: Video

    private let width: CGFloat = 340
    private let height: CGFloat = 180
    private let cornerRadius: CGFloat = 12

    @State private var isPlaying = false

    var body: some View {
        Group {
            if isPlaying {
                VideoView(videoID: video.key, autoplay: true)
            } else {
                thumbnail
            }
        }
        .frame(width: width, height: height)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var thumbnail: some View {
        Button {
            isPlaying = true
        } label: {
            ZStack {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.black
                } failure: { _ in
                    Color.black
                }
                .frame(width: width, height: height)
                .clipped()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 56))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.45))
                    .shadow(radius: 4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("playTrailer"))
    }

    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(video.key)/hqdefault.jpg")
    }
}
