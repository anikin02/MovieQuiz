//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Данил on 19/09/2026.
//

protocol StatisticServiceProtocol {
  var gamesCount: Int { get }
  var bestGame: GameResult { get }
  var totalAccuracy: Double { get }
  
  func store(gameResult: GameResult)
}
