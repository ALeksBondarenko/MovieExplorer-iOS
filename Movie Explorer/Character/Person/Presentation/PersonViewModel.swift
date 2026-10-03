//
//  PersonViewModel.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 27.12.2025.
//

import Foundation
import Combine

@MainActor
final class PersonViewModel: ViewModel {

    private let repository: PersonRepository
    private let cast: Cast

    @Published private(set) var state: PersonState = .loading
    let movies: Paginator<Movie>

    init(repository: PersonRepository, cast: Cast) {
        self.repository = repository
        self.cast = cast
        self.movies = Paginator<Movie> { [repository, personId = cast.id] page in
            try await repository.getMoviesWithPerson(personId: personId, page: page)
        }
    }

    /// Loads the person once; returning to the screen does not reload it.
    func load() {
        movies.loadIfNeeded()
        if case .content = state { return }
        addTask { @MainActor [weak self] in
            await self?.loadPerson()
        }
    }

    /// Repeats the failed initial load.
    func retry() {
        state = .loading
        load()
    }

    func refresh() async {
        await loadPerson()
        await movies.refresh()
    }

    private func loadPerson() async {
        do {
            async let personResult = repository.getPerson(personId: cast.id)
            async let photosResult = repository.getPersonImages(personId: cast.id)

            let (person, photos) = try await (personResult, photosResult)
            state = .content(person, photos)
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            log(error)
            if case .content = state { return }   // keep shown data on a failed refresh
            state = .error(error)
        }
    }
}
