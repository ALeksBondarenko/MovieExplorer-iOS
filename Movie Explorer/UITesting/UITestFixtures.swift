//
//  UITestFixtures.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 04.10.2026.
//

#if DEBUG
import Foundation

/// Fixed data returned by the UI test stubs.
/// Keep ids and names in sync with `Fixtures` in the UI test target.
enum UITestFixtures {

    static let pageSize = 20

    static let popularPage1 = movies(1...20, title: "Movie")
    static let popularPage2 = movies(21...40, title: "Movie")
    static let genreMovies = movies(101...106, title: "Action Movie", offset: 100)
    static let similarMovies = movies(201...205, title: "Similar", offset: 200)
    static let personMovies = movies(301...303, title: "Filmography", offset: 300)
    static let searchMovies = movies(401...403, title: "Found Movie", offset: 400)
    static let favoriteMovies = movies(801...803, title: "Favorite Movie", offset: 800)
    static let watchListMovies = movies(901...902, title: "Watch Movie", offset: 900)

    static let genre = Genres(id: 28, name: "Action")

    static let cast = [
        Cast(id: 501, character: "Hero", name: "Actor One", profilePath: nil),
        Cast(id: 502, character: "Villain", name: "Actor Two", profilePath: nil),
    ]

    static let searchPerson = Cast(id: 601, character: nil, name: "Found Person", profilePath: nil)

    static let searchKeyword = Keyword(id: 701, name: "toy story")

    static let trailer = Video(key: "uitest123", site: "YouTube", type: "Trailer", official: true)

    /// Query that returns no search results.
    static let emptySearchQuery = "nothing"

    static func title(ofMovie id: Int) -> String {
        allMovies.first { $0.id == id }?.title ?? "Movie \(id)"
    }

    static func name(ofPerson id: Int) -> String {
        (cast + [searchPerson]).first { $0.id == id }?.name ?? "Person \(id)"
    }

    static func page(_ movies: [Movie], page: Int = 1, totalPages: Int = 1) -> Page {
        Page(page: page, results: movies, totalPages: totalPages)
    }

    // MARK: - Private

    private static var allMovies: [Movie] {
        popularPage1 + popularPage2 + genreMovies + similarMovies + personMovies
            + searchMovies + favoriteMovies + watchListMovies
    }

    private static func movies(_ ids: ClosedRange<Int>, title: String, offset: Int = 0) -> [Movie] {
        ids.map { id in
            Movie(
                id: id,
                title: "\(title) \(id - offset)",
                overview: "Overview of \(title) \(id - offset)",
                posterPath: nil,
                releaseDate: nil
            )
        }
    }
}
#endif
