//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Данил on 24/09/2026.
//
import Foundation

struct MostPopularMovies: Codable {
  let errorMessage: String?
  let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
  let title: String
  let rating: Float
  let imageURL: URL
  
  var resizedImageURL: URL {
    let urlString = imageURL.absoluteString
    let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V1_w800_h1200_AL_.jpg"
    
    guard let newURL = URL(string: imageUrlString) else {
      return imageURL
    }
    
    return newURL
  }
  
  private enum CodingKeys: String, CodingKey {
    case title = "fullTitle"
    case rating = "imDbRating"
    case imageURL = "image"
  }
}
