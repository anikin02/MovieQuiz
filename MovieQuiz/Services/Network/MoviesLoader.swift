//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Данил on 24/09/2026.
//

import Foundation

protocol MoviesLoading {
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
  // MARK: - NetworkClient
  private let networkClient: NetworkClient = NetworkClient()
  
  // MARK: - URL
  private let stringUrl: String = "https://tv-api.com/api/top-250-movies?apikey=juv0ohccyeycmvbwn4du"
  private var mostPopularMoviesUrl: URL {
    guard let url = URL(string: stringUrl) else {
      preconditionFailure("Unable to construct mostPopularMoviesUrl")
    }
    return url
  }
  
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
    networkClient.fetch(url: mostPopularMoviesUrl) { result in
      switch result {
        case .success(let data):
          do {
            let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            handler(.success(mostPopularMovies))
          }
          catch {
            handler(.failure(error))
          }
        case .failure(let error):
          handler(.failure(error))
      }
    }
  }
}
