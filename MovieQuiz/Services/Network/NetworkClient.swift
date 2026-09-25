//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Данил on 24/09/2026.
//

import Foundation

struct NetworkClient {
  
  private enum NetworkError: Error {
    case codeError
  }
  
  func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
    let request = URLRequest(url: url)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        handler(.failure(error))

        return
      }
      
      let happyStatusCodes = 200..<300
      
      if let response = response as? HTTPURLResponse,
         !happyStatusCodes.contains(response.statusCode) {
        handler(.failure(NetworkError.codeError))
        return
      }
      
      guard let data = data else { return }
      handler(.success(data))
    }
    
    task.resume()
  }
}



