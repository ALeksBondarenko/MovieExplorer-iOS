//
//  MovieUIView.swift
//  Movie Explorer
//
//  Created by Александр Бондаренко on 06.12.2025.
//

import SwiftUI

struct MovieDetailsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: MovieDetailsViewModel

    @State private var selectedImageIndex: Int = 0
    @State private var isShowingImageGallery = false
    
    init(viewModel: @autoclosure @escaping () -> MovieDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                FullScreenProgressView()
            case .success(
                let movie,
                let images,
                let videos,
                let casts,
                let favorite,
                let watchLater
            ):
                MovieDetailsView(
                    movieDetails: movie,
                    images: images,
                    videos: videos,
                    casts: casts,
                    favorite: favorite,
                    watchLater: watchLater
                ).alerError(
                    error: viewModel.similar.error,
                    onRetry: { viewModel.similar.retry() },
                    onCancel: { viewModel.similar.clearError() }
                )
            case .failure(let error):
                ErrorView(
                    error: error,
                    onRetry: viewModel.retry,
                    onCancel: { dismiss() }
                )
            }
        }
        .onAppear {
            viewModel.requestDetails()
        }
    }

    @ViewBuilder
    func MovieDetailsView(
        movieDetails: MovieDetails,
        images: [Frame],
        videos: [Video],
        casts: [Cast],
        favorite: Bool,
        watchLater: Bool
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Header(movieDetails: movieDetails, image: images.first)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(movieDetails.genres, id: \.id) { genre in
                            NavigationLink(value: Route.genre(genre)) {
                                Text(genre.name)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue)
                                    .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("genre.\(genre.id)")
                        }
                    }.padding(.horizontal)
                }.padding(.top)

                if !movieDetails.overview.isEmpty {
                    Text("overview")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)

                    Text(movieDetails.overview)
                        .font(.body)
                        .truncationEffect(lenght: 3, moreText: "more", animation: .smooth(duration: 0.5, extraBounce: 0))
                        .padding(.horizontal)
                }

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 4) {
                            ForEach(Array(images.enumerated()), id: \.element.filePath) { index, image in
                                CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(image.filePath)")) { image in
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
                                    selectedImageIndex = index
                                    isShowingImageGallery = true
                                }
                                .frame(width: 340, height: 180)
                                .id(index)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .onChange(of: selectedImageIndex) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .fullScreenCover(isPresented: $isShowingImageGallery) {
                    ImageGalleryView(
                        images: images.map(\.filePath),
                        currentIndex: $selectedImageIndex
                    )
                }

                if !videos.isEmpty {
                    Text("trailers")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(videos, id: \.key) { video in
                                TrailerView(video: video)
                            }
                        }.padding(.horizontal)
                    }
                }

                if !casts.isEmpty {
                    Text("cast")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(casts, id: \.id) { cast in
                                NavigationLink(value: Route.person(cast)) {
                                    PersonView(cast: cast)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("person.\(cast.id)")
                            }
                        }.padding(.horizontal)
                    }
                }
                
                if !viewModel.similar.items.isEmpty {
                    Text("similarMovies")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .padding(.top, 12)
                        .padding(.horizontal)

                    MoviesRowView(paginator: viewModel.similar)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleWatchLater()
                } label: {
                    Label(
                        "watchLater",
                        systemImage: watchLater ? "bookmark.fill" : "bookmark"
                    )
                    .foregroundColor(watchLater ? .red : .gray)
                }
                // The state is in the identifier: SwiftUI does not pass custom traits to toolbar buttons.
                .accessibilityIdentifier("details.watchLaterButton.\(watchLater ? "on" : "off")")
                .accessibilityAddTraits(watchLater ? .isSelected : [])
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorites()
                } label: {
                    Label(
                        "favorite",
                        systemImage: favorite ? "heart.fill" : "heart"
                    )
                    .foregroundColor(favorite ? .red : .gray)
                }
                .accessibilityIdentifier("details.favoriteButton.\(favorite ? "on" : "off")")
                .accessibilityAddTraits(favorite ? .isSelected : [])
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    func Header(movieDetails: MovieDetails, image: Frame?) -> some View {
        ZStack(alignment: .leading) {
            CachedAsyncImage(
                url: URL(
                    string:
                        "https://image.tmdb.org/t/p/w1280\(movieDetails.backdropPath ?? image?.filePath ?? "")"
                )
            ) { image in
                image.resizable()
            } placeholder: {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear, Color("AlertBackground"),
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            } failure: { _ in
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear, Color("AlertBackground"),
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            .aspectRatio(contentMode: .fit)
            .overlay {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear, Color("Background"),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .stretchable()

            HStack(alignment: .bottom) {
                AsyncPosterImage(posterPath: movieDetails.posterPath)

                VStack(alignment: .leading) {
                    Text(movieDetails.title)
                        .font(.title.bold())
                        .accessibilityIdentifier("details.title")

                    if movieDetails.voteAverage > 0 {
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(
                                .yellow
                            )
                            Text(
                                "\(movieDetails.voteAverage, specifier: "%.1f")"
                            )
                            .font(.caption)
                        }
                    }

                    if let releaseDate = movieDetails.releaseDate {
                        Text(releaseDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading)
            }
            .padding(.top, 120)
            .padding(.horizontal)
        }
    }
}

extension View {

    fileprivate func stretchable() -> some View {
        visualEffect { effect, geometry in
            let frame = geometry.frame(in: .scrollView)

            let offset: CGFloat = frame.minY
            let currentLength: CGFloat = geometry.size.height

            let positiveOffset = max(0, offset)
            let scale =
                (currentLength + positiveOffset) / max(currentLength, 0.0001)

            return effect.scaleEffect(x: scale, y: scale, anchor: .bottom)
        }
    }
}

#Preview {
    MovieDetailsScreen(
        viewModel: MovieDetailsViewModel(
            repository: MovieDetailRepositoryImpl(
                service: MovieDetailsService(
                    networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(
                            sessionStore: KeychainSessionStore()
                        ),
                        urlSession: .shared
                    )
                ),
                authRepository: AuthRepositoryImpl(
                    service: AuthService(
                        networkClient: NetworkClient(
                            connectionErrorMapper: ConnectionErrorMapper(),
                            sessionTokenProvider: DefaultSessionTokenProvider(
                                sessionStore: KeychainSessionStore()
                            ),
                            urlSession: .shared
                        )
                    ),
                    sessionStore: KeychainSessionStore(),
                    webAuthPresenter: WebAuthPresenter()
                )
            ),
            authRepository: AuthRepositoryImpl(
                service: AuthService(
                    networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(
                            sessionStore: KeychainSessionStore()
                        ),
                        urlSession: .shared
                    )
                ),
                sessionStore: KeychainSessionStore(),
                webAuthPresenter: WebAuthPresenter()
            ),
            movie: Movie(
                id: 1_022_787,
                title: "Elio",
                overview: "overview",
                posterPath: "posterPath",
                releaseDate: Date()
            )
        )
    )
    .preferredColorScheme(ColorScheme.dark)
}

#Preview {
    MovieDetailsScreen(
        viewModel: MovieDetailsViewModel(
            repository: MovieDetailRepositoryImpl(
                service: MovieDetailsService(
                    networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(
                            sessionStore: KeychainSessionStore()
                        ),
                        urlSession: .shared
                    )
                ),
                authRepository: AuthRepositoryImpl(
                    service: AuthService(
                        networkClient: NetworkClient(
                            connectionErrorMapper: ConnectionErrorMapper(),
                            sessionTokenProvider: DefaultSessionTokenProvider(
                                sessionStore: KeychainSessionStore()
                            ),
                            urlSession: .shared
                        )
                    ),
                    sessionStore: KeychainSessionStore(),
                    webAuthPresenter: WebAuthPresenter()
                )
            ),
            authRepository: AuthRepositoryImpl(
                service: AuthService(
                    networkClient: NetworkClient(
                        connectionErrorMapper: ConnectionErrorMapper(),
                        sessionTokenProvider: DefaultSessionTokenProvider(
                            sessionStore: KeychainSessionStore()
                        ),
                        urlSession: .shared
                    )
                ),
                sessionStore: KeychainSessionStore(),
                webAuthPresenter: WebAuthPresenter()
            ),
            movie: Movie(
                id: 1_022_787,
                title: "Elio",
                overview: "overview",
                posterPath: "posterPath",
                releaseDate: Date()
            )
        )
    )
}
