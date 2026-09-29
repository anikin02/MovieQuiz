//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Данил on 28/09/2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
  // MARK: - Properties
  private weak var viewController: MovieQuizViewControllerProtocol?
  private var questionFactory: QuestionFactoryProtocol?
  private var statisticService: StatisticServiceProtocol = StatisticService()
  
  private let questionsAmount: Int = 10
  private var currentQuestionIndex: Int = 0
  private var correctAnswers = 0
  private var currentQuestion: QuizQuestion?
  
  // MARK: - Init
  init(viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    questionFactory?.loadData()
    viewController.showLoadingIndicator()
  }
  
  // MARK: - QuestionFactoryDelegate
  func didLoadDataFromServer() {
    viewController?.hideLoadingIndicator()
    questionFactory?.requestNextQuestion()
  }
  
  func didFailToLoadData(with error: Error) {
    let message = error.localizedDescription
    viewController?.showNetworkError(message: message)
  }
  
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question else { return }
    
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.viewController?.show(quiz: viewModel)
    }
  }
  
  // MARK: - Public functions
  func yesButtonClicked() {
    proccessAnswer(givenAnswer: true)
  }
  
  func noButtonClicked() {
    proccessAnswer(givenAnswer: false)
  }
  
  func restartGame() {
    currentQuestionIndex = 0
    correctAnswers = 0
    questionFactory?.requestNextQuestion()
  }
  
  func convert(model: QuizQuestion) -> QuizStepViewModel {
    return QuizStepViewModel(
      image:  model.image,
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
  }
  
  // MARK: - Private functions
  private func proceedNextQuestionOrResults() {
    if isLastQuestion() {
      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: makeResultsMessage(),
        buttonText: "Сыграть еще раз?")
      viewController?.show(quiz: result)
    } else {
      switchToNextQuestion()
      questionFactory?.requestNextQuestion()
    }
  }
  
  private func proceedWithAnswer(isCorrect: Bool) {
    didAnswer(isCorrectAnswer: isCorrect)
    
    viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      self.proceedNextQuestionOrResults()
    }
  }
  
  private func proccessAnswer(givenAnswer: Bool) {
    guard let currentQuestion else { return }
    
    proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
  }
  
  private func makeResultsMessage() -> String {
    statisticService.store(gameResult: GameResult(correct: correctAnswers, total: questionsAmount, date: Date()))
    
    let text = """
    Ваш результат: \(correctAnswers)/\(questionsAmount)
    Количество сыгранных квизов: \(statisticService.gamesCount)
    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
    """
    
    return text
  }
  
  private func isLastQuestion() -> Bool {
    currentQuestionIndex == questionsAmount - 1
  }
  
  private func didAnswer(isCorrectAnswer: Bool) {
    if isCorrectAnswer {
      correctAnswers += 1
    }
  }
  
  private func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
}
