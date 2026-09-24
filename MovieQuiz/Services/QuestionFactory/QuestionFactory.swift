//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Данил on 17/09/2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
  private let questions: [QuizQuestion] = QuizQuestion.mocks
  
  private weak var delegate: QuestionFactoryDelegate?
  private let moviesLoader: MoviesLoading
  private var movies: [MostPopularMovie] = []
  
  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }
  
  func loadData() {
    moviesLoader.loadMovies() { [weak self] result in
      DispatchQueue.main.async {
        guard let self else { return }
        switch result {
          case .success(let movies):
            self.movies = movies.items
            self.delegate?.didLoadDataFromServer()
          case .failure(let error):
            self.delegate?.didFailToLoadData(with: error)
        }
      }
    }
  }
  
  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      let index = (0..<self.movies.count).randomElement() ?? 0
      
      guard let movie = self.movies[safe: index] else { return }
      
      var imageData = Data()
      
      do {
        imageData = try Data(contentsOf: movie.resizedImageURL)
      } catch {
        print("Failed to load image")
      }
      
      let question = generateQuestion(imageData: imageData, movie: movie)
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
  
  private func generateQuestion(imageData: Data, movie: MostPopularMovie) -> QuizQuestion {
    enum Comparison: String, CaseIterable {
      case bigger = "больше"
      case smaller = "меньше"
    }
    
    let proposedRating = Int.random(in: 7...9)
    let proposedCompare = Comparison.allCases.randomElement() ?? .bigger
    
    let text = "Рейтинг этого фильма \(proposedCompare.rawValue) чем \(proposedRating)?"
    
    var correctAnswer: Bool
    
    switch proposedCompare {
      case .bigger:
        correctAnswer = movie.rating > Float(proposedRating)
      case .smaller:
        correctAnswer = movie.rating < Float(proposedRating)
    }
    
    return QuizQuestion(image: imageData,
                        text: text,
                        correctAnswer: correctAnswer)
  }
}
