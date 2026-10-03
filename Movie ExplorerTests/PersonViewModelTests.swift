//
//  PersonViewModelTests.swift
//  Movie ExplorerTests
//
//  Created by Александр Бондаренко on 27.01.2026.
//

import Testing
@testable import Movie_Explorer
import Foundation

@MainActor
struct PersonViewModelTests {

    let cast = Cast(id: 1, character: nil, name: nil, profilePath: nil)

    final class MockPersonRepository: PersonRepository {
        var person: Person?
        var errorPerson: Error?

        var images: [PersonImage] = []
        var errorImages: Error?

        var pages: [Int: Page] = [:]
        var errors: [Int: Error] = [:]
        var delayNanosecondsByPage: [Int: UInt64] = [:]
        private(set) var personCallCount = 0
        private(set) var requestedPages: [Int] = []

        func getPerson(personId: Int) async throws -> Person {
            personCallCount += 1
            if let error = errorPerson {
                throw error
            }
            guard let person else {
                Issue.record("person is not set")
                throw MockError.error
            }
            return person
        }

        func getPersonImages(personId: Int) async throws -> [PersonImage] {
            if let error = errorImages {
                throw error
            }
            return images
        }

        func getMoviesWithPerson(personId: Int, page: Int) async throws -> Page {
            requestedPages.append(page)
            if let delay = delayNanosecondsByPage[page], delay > 0 {
                try await Task.sleep(nanoseconds: delay)
            }
            if let error = errors[page] {
                throw error
            }
            guard let result = pages[page] else {
                Issue.record("Page \(page) not found")
                throw MockError.error
            }
            return result
        }
    }

    enum MockError: Error {
        case error
    }

    let firstMovie = Movie(id: 1, title: "Toy Story", overview: "", posterPath: nil, releaseDate: nil)
    let secondMovie = Movie(id: 2, title: "Finding Nemo", overview: "", posterPath: nil, releaseDate: nil)
    let thirdMovie = Movie(id: 3, title: "Cars", overview: "", posterPath: nil, releaseDate: nil)
    let person1 = Person(id: 1, name: "Tom Hanks", profilePath: "profilePath", biography: "biography", birthday: nil, deathday: nil, placeOfBirth: "placeOfBirth")

    @Test
    func testSuccessfulInitialLoad() async {
        let repository = MockPersonRepository()
        let images = [PersonImage(filePath: "filePath")]
        repository.person = person1
        repository.images = images
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)
        await waitUntilSettled(viewModel.movies)

        guard case let .content(person, personImages) = viewModel.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(person == person1)
        #expect(personImages == images)
        #expect(viewModel.movies.items == [firstMovie])
    }

    @Test
    func testInitialLoadFailureSetsErrorState() async {
        let repository = MockPersonRepository()
        repository.errorPerson = MockError.error
        repository.pages[1] = Page(page: 1, results: [], totalPages: 1)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)

        if case .error = viewModel.state {
            // ok
        } else {
            Issue.record("Expected error state when the initial load fails")
        }
    }

    @Test
    func testMoviesFailureDoesNotHideThePerson() async {
        let repository = MockPersonRepository()
        repository.person = person1
        repository.errors[1] = MockError.error

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)
        await waitUntilSettled(viewModel.movies)

        guard case .content = viewModel.state else {
            Issue.record("Expected content state even if movies failed")
            return
        }
        guard case .failed = viewModel.movies.phase else {
            Issue.record("Expected movies to fail")
            return
        }
    }

    @Test
    func testLoadDoesNotReloadLoadedPerson() async {
        let repository = MockPersonRepository()
        repository.person = person1
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)
        await waitUntilSettled(viewModel.movies)

        // Returning to the screen calls load() again.
        viewModel.load()
        await Task.yield()

        #expect(repository.personCallCount == 1)
        #expect(repository.requestedPages == [1])
    }

    @Test
    func testRetryAfterFailureLoadsPersonAgain() async {
        let repository = MockPersonRepository()
        repository.errorPerson = MockError.error
        repository.pages[1] = Page(page: 1, results: [], totalPages: 1)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)

        repository.errorPerson = nil
        repository.person = person1
        viewModel.retry()
        await waitForContentOrError(viewModel: viewModel)

        guard case let .content(person, _) = viewModel.state else {
            Issue.record("Expected content state after retry")
            return
        }
        #expect(person == person1)
    }

    @Test
    func testMoviesLoadNextPage() async {
        let repository = MockPersonRepository()
        repository.person = person1
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 2)
        repository.pages[2] = Page(page: 2, results: [secondMovie], totalPages: 2)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitUntilSettled(viewModel.movies)
        viewModel.movies.loadMoreIfNeeded(after: firstMovie)
        await waitUntilSettled(viewModel.movies)

        #expect(viewModel.movies.items == [firstMovie, secondMovie])
        #expect(repository.requestedPages == [1, 2])
    }

    @Test
    func testRefreshReloadsPersonAndMovies() async {
        let repository = MockPersonRepository()
        repository.person = person1
        repository.pages[1] = Page(page: 1, results: [firstMovie], totalPages: 1)

        let viewModel = PersonViewModel(repository: repository, cast: cast)

        viewModel.load()
        await waitForContentOrError(viewModel: viewModel)
        await waitUntilSettled(viewModel.movies)

        repository.pages[1] = Page(page: 1, results: [thirdMovie], totalPages: 1)
        await viewModel.refresh()

        #expect(repository.personCallCount == 2)
        #expect(viewModel.movies.items == [thirdMovie])
    }
}

@MainActor
private func waitForContentOrError(viewModel: PersonViewModel) async {
    let deadline = Date().addingTimeInterval(3)
    while Date() < deadline {
        switch viewModel.state {
        case .loading:
            await Task.yield()
        case .content, .error:
            return
        }
    }
}
