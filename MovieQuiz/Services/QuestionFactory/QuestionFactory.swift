//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Данил on 17/09/2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
  private let questions: [QuizQuestion] = QuizQuestion.mocks
  
  weak var delegate: QuestionFactoryDelegate?
  
  func requestNextQuestion() {
    guard let index = (0..<questions.count).randomElement() else {
      delegate?.didReceiveNextQuestion(question: nil)
      return
    }
    
    let question = questions[safe: index]
    delegate?.didReceiveNextQuestion(question: question)
  }
}
