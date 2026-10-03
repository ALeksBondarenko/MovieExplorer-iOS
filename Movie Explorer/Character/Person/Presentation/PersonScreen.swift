//
//  PersonView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 27.12.2025.
//

import SwiftUI

struct PersonScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhotoIndex: Int = 0
    @State private var isShowingPhotoGallery = false
    
    @StateObject var viewModel: PersonViewModel
    
    init(viewModel: @autoclosure @escaping () -> PersonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                FullScreenProgressView()
            case .content(let person, let photos):
                PersonView(person: person, photos: photos)
                    .alerError(
                        error: viewModel.movies.error,
                        onRetry: { viewModel.movies.retry() },
                        onCancel: { viewModel.movies.clearError() }
                    )
            case .error(let error):
                ErrorView(error: error, onRetry: viewModel.retry, onCancel: { dismiss() })
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    @ViewBuilder
    func PersonView(person: Person, photos: [PersonImage]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Header(person: person)
                    .padding(.horizontal)
                
                Spacer()
                
                if !person.biography.isEmpty {
                    Text("biography")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    
                    Text(person.biography)
                        .font(.caption)
                        .truncationEffect(lenght: 3, moreText: "more", animation: .smooth(duration: 0.5, extraBounce: 0))
                        .padding(.horizontal)
                }
                
                if !photos.isEmpty {
                    Text("photo")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding(.top, 12)
                        .padding(.horizontal)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(Array(photos.enumerated()), id: \.element.filePath) { index, photo in
                                    CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/h632\(photo.filePath)")) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    } failure: { _ in
                                        ProgressView()
                                    }
                                    .cornerRadius(16)
                                    .aspectRatio(contentMode: .fit)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedPhotoIndex = index
                                        isShowingPhotoGallery = true
                                    }
                                    .frame(width: 160, height: 240)
                                    .id(index)
                                }
                            }.padding(.horizontal)
                        }
                        .onChange(of: selectedPhotoIndex) { _, newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingPhotoGallery) {
                        ImageGalleryView(
                            images: photos.map(\.filePath),
                            currentIndex: $selectedPhotoIndex
                        )
                    }
                }
                
                if !viewModel.movies.items.isEmpty {
                    Text("movies")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding(.top, 12)
                        .padding(.horizontal)

                    MoviesRowView(paginator: viewModel.movies)
                }
            }
        }.refreshable {
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder
    func Header(person: Person)  -> some View {
        HStack(alignment: .top) {
            CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/h632\(person.profilePath ?? "" )")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            } failure: { _ in
                
            }
            .frame(width: 160, height: 240)
            .cornerRadius(16)
            .aspectRatio(contentMode: .fit)
            .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.title.bold())
                    .accessibilityIdentifier("person.name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let placeOfBirth = person.placeOfBirth {
                    Text(placeOfBirth)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let birthday = person.birthday {
                    Text(birthday, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    PersonScreen(viewModel: PersonViewModel(repository: PersonRepositoryImpl(service: PersonService(networkClient: NetworkClient(
        connectionErrorMapper: ConnectionErrorMapper(),
        sessionTokenProvider: DefaultSessionTokenProvider(sessionStore: KeychainSessionStore()),
        urlSession: .shared
    ))), cast: Cast(id: 16828, character: "Buzz Lightyear (voice)", name: "Chris Evans", profilePath: "/3bOGNsHlrswhyW79uvIHH1V43JI.jpg")))
}
