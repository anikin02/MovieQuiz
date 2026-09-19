//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Данил on 19/09/2026.
//

import Foundation

struct GameResult {
  let correct: Int
  let total: Int
  let date: Date
  
  func isBetterThan(lastBestResult: GameResult) -> Bool {
    return correct > lastBestResult.correct
  }
}
