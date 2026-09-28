//
//  MoviesLoaderTests.swift
//  MovieQuiz
//
//  Created by Данил on 25/09/2026.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
  func testSuccessLoading() throws {
    // Given
    let stubNetworkClient = StubNetworkClient(emulateError: false)
    let loader = MoviesLoader(networkClient: stubNetworkClient)
    
    // When
    let expectation = expectation(description: "Loading expectation")
    
    loader.loadMovies { result in
      // Then
      switch result {
        case .success(let movies):
          XCTAssertEqual(movies.items.count, 2)
          expectation.fulfill()
        case .failure(_):
          XCTFail("Unexpected failure")
      }
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testFailureLoading() throws {
    // Given
    let stubNetworkClient = StubNetworkClient(emulateError: true)
    let loader = MoviesLoader(networkClient: stubNetworkClient)
    
    // When
    let expectation = expectation(description: "Loading expectation")
    
    loader.loadMovies { result in
      // Then
      switch result {
        case .success(_):
          XCTFail("Unexpected success")
        case .failure(let error):
          XCTAssertNotNil(error)
          expectation.fulfill()
      }
    }
    
    waitForExpectations(timeout: 1)
  }
}

struct StubNetworkClient: NetworkRouting {
  
  enum TestError: Error {
    case test
  }
  
  let emulateError: Bool
  
  func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
    if emulateError {
      handler(.failure(TestError.test))
    } else {
      handler(.success(expectedResponse))
    }
  }
  
  private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                    "rank": 1,
                    "imDbId": "tt0111161",
                    "title": "The Shawshank Redemption",
                    "fullTitle": "The Shawshank Redemption (1994)",
                    "type": "Movie",
                    "year": 1994,
                    "image": "https://m.media-amazon.com/images/M/MV5BMDAyY2FhYjctNDc5OS00MDNlLThiMGUtY2UxYWVkNGY2ZjljXkEyXkFqcGc@._V1_w1200_h1800_AL_.jpg",
                    "runtimeMins": 142,
                    "runtimeStr": "142 mins",
                    "contentRating": "R",
                    "imDbRating": 9.3,
                    "imDbRatingVotes": 3242237,
                    "genres": "Drama",
                    "genreList": [
                      {
                        "key": "Drama",
                        "value": "Drama"
                      }
                    ]
                  },
                  {
                    "rank": 2,
                    "imDbId": "tt0068646",
                    "title": "The Godfather",
                    "fullTitle": "The Godfather (1972)",
                    "type": "Movie",
                    "year": 1972,
                    "image": "https://m.media-amazon.com/images/M/MV5BNGEwYjgwOGQtYjg5ZS00Njc1LTk2ZGEtM2QwZWQ2NjdhZTE5XkEyXkFqcGc@._V1_w1396_h1982_AL_.jpg",
                    "runtimeMins": 175,
                    "runtimeStr": "175 mins",
                    "contentRating": "R",
                    "imDbRating": 9.2,
                    "imDbRatingVotes": 2258419,
                    "genres": "Crime, Drama",
                    "genreList": [
                      {
                        "key": "Crime",
                        "value": "Crime"
                      },
                      {
                        "key": "Drama",
                        "value": "Drama"
                      }
                    ]
                  }
            ]
          }
        """.data(using: .utf8) ?? Data()
  }
}

