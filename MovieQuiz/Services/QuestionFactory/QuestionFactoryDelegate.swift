//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Данил on 18/09/2026.
//

protocol QuestionFactoryDelegate: AnyObject {
  func didReceiveNextQuestion(question: QuizQuestion?)
  func didLoadDataFromServer()
  func didFailToLoadData(with error: Error)
}
