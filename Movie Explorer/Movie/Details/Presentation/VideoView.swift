//
//  VideoView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 11.12.2025.
//

import SwiftUI
import WebKit

struct VideoView: UIViewRepresentable {

    let videoID: String
    var autoplay: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        load(into: webView, coordinator: context.coordinator)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedVideoID != Self.sanitize(videoID) else { return }
        load(into: webView, coordinator: context.coordinator)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
        coordinator.loadedVideoID = nil
    }

    private func load(into webView: WKWebView, coordinator: Coordinator) {
        let id = Self.sanitize(videoID)
        coordinator.loadedVideoID = id
        webView.loadHTMLString(
            Self.embedHTML(videoID: id, autoplay: autoplay),
            baseURL: URL(string: "https://www.youtube-nocookie.com")
        )
    }

    private static func sanitize(_ raw: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return String(raw.unicodeScalars.prefix { allowed.contains($0) }.map(Character.init))
    }

    private static func embedHTML(videoID: String, autoplay: Bool) -> String {
        let params = [
            "playsinline=1",
            "modestbranding=1",
            "rel=0",
            autoplay ? "autoplay=1" : nil
        ]
        .compactMap { $0 }
        .joined(separator: "&")

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                html, body { margin: 0; padding: 0; height: 100%; background: #000; }
                iframe { display: block; width: 100%; height: 100%; border: 0; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube-nocookie.com/embed/\(videoID)?\(params)"
                allow="autoplay; encrypted-media; picture-in-picture; fullscreen"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
    }

    final class Coordinator {
        var loadedVideoID: String?
    }
}
