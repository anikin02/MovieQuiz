//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Данил on 19/09/2026.
//

import Foundation

final class StatisticService {
  private let storage: UserDefaults = .standard
  
  private enum Keys: String {
    case gamesCount
    case bestGameCorrect
    case bestGameTotal
    case bestGameDate
    case totalCorrectAnswers
    case totalQuestionsAsked
  }
  
}

extension StatisticService: StatisticServiceProtocol {
  var gamesCount: Int {
    get {
      storage.integer(forKey: Keys.gamesCount.rawValue)
    }
    set {
      storage.set(newValue, forKey: Keys.gamesCount.rawValue)
    }
  }
  
  var bestGame: GameResult {
    get {
      GameResult(correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                 total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                 date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date())
    }
    set {
      storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
      storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
      storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
    }
  }
  
  var totalAccuracy: Double {
    Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
  }
  
  private var totalQuestionsAsked: Int {
    get {
      UserDefaults.standard.integer(forKey: Keys.totalQuestionsAsked.rawValue)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
    }
  }
  
  private var totalCorrectAnswers: Int {
    get {
      UserDefaults.standard.integer(forKey: Keys.totalCorrectAnswers.rawValue)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
    }
  }
  
  func store(gameResult: GameResult) {
    gamesCount += 1
    totalCorrectAnswers += gameResult.correct
    totalQuestionsAsked += gameResult.total
    
    bestGame = gameResult.isBetterThan(lastBestResult: bestGame) ? gameResult : bestGame
  }
}
