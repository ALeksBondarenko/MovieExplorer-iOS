//
//  Logger.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 04.02.2026.
//

import Foundation

nonisolated private enum LogConfig {
    static let appName = "MOVIE EXPLORER"
    /// Header names never printed to the log, regardless of direction (request or response).
    static let sensitiveHeaderKeys: Set<String> = ["etag", "if-none-match"]
}


nonisolated func log(
    _ error: Error,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    print("\(LogConfig.appName): [\(file):\(line)] \(function) — \(error)")
    #endif
}

nonisolated func logRequest(httpMethod: HttpMethod, request: URLRequest) {
    #if DEBUG
    print("--------------------------------------------------------------------------------")
    print("\(LogConfig.appName): Request: \(httpMethod.name) \(request.url?.absoluteString ?? httpMethod.path)")
    print("\(LogConfig.appName): Headers: \(sanitizedHeaders(request.allHTTPHeaderFields))")
    print("--------------------------------------------------------------------------------")
    #endif
}

nonisolated func logResponse(_ response: URLResponse) {
    #if DEBUG
    print("--------------------------------------------------------------------------------")
    if let httpResponse = response as? HTTPURLResponse {
        print("\(LogConfig.appName): Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")
        print("\(LogConfig.appName): Headers: \(sanitizedHeaders(httpResponse.allHeaderFields))")
    } else {
        print("\(LogConfig.appName): Response: \(response.url?.absoluteString ?? "")")
    }
    print("--------------------------------------------------------------------------------")
    #endif
}

/// Logs the response body exactly as received over the wire, before any decoding is attempted —
/// so it stays useful even when decoding into a DTO fails or the status code isn't 2xx.
nonisolated func logBody(_ data: Data) {
    #if DEBUG
    print("--------------------------------------------------------------------------------")
    print("\(LogConfig.appName): Response body: \(String(data: data, encoding: .utf8) ?? "<\(data.count) bytes, not UTF-8>")")
    print("--------------------------------------------------------------------------------")
    #endif
}

nonisolated private func sanitizedHeaders(_ headers: [String: String]?) -> [String: String] {
    guard let headers else { return [:] }
    return headers.filter { !LogConfig.sensitiveHeaderKeys.contains($0.key.lowercased()) }
}

nonisolated private func sanitizedHeaders(_ headers: [AnyHashable: Any]) -> [String: String] {
    var result: [String: String] = [:]
    for (key, value) in headers {
        guard let key = key as? String, !LogConfig.sensitiveHeaderKeys.contains(key.lowercased()) else {
            continue
        }
        result[key] = String(describing: value)
    }
    return result
}
