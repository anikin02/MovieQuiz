import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
  // MARK: - IBOutlet
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet weak var noButton: UIButton!
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Properties
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  private let questionsAmount: Int = 10
  private var questionFactory: QuestionFactoryProtocol?
  private var currentQuestion: QuizQuestion?
  private var alertPresenter = AlertPresenter()
  private var statisticService: StatisticServiceProtocol = StatisticService()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureImageView()
    
    showLoadingIndicator()
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    questionFactory?.loadData()
  }
  
  // MARK: - QuestionFactoryDelegate
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question = question else { return }
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async {
      self.show(quiz: viewModel)
    }
  }
  
  func didLoadDataFromServer() {
    questionFactory?.requestNextQuestion()
    hideLoadingIndicator()
  }
  
  func didFailToLoadData(with error: any Error) {
    showNetworkError(message: error.localizedDescription)
  }
  
  // MARK: - IBAction
  @IBAction private func yesButtonClicked(_ sender: Any) {
    proccessAnswer(givenAnswer: true)
    setButtonsEnabled(false)
  }
  
  @IBAction private func noButtonClicked(_ sender: Any) {
    proccessAnswer(givenAnswer: false)
    setButtonsEnabled(false)
  }
  
  // MARK: - Private Methods
  private func proccessAnswer(givenAnswer: Bool) {
    guard let currentQuestion = currentQuestion else {
      return
    }
    showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
  }
  
  private func setButtonsEnabled(_ isEnabled: Bool) {
    noButton.isEnabled = isEnabled
    yesButton.isEnabled = isEnabled
  }
  
  private func configureImageView() {
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 20
  }
  
  private func convert(model: QuizQuestion) -> QuizStepViewModel {
    return QuizStepViewModel(
      image: UIImage(data: model.image) ?? UIImage(),
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
  }
  
  private func show(quiz step: QuizStepViewModel) {
    counterLabel.text = step.questionNumber
    imageView.image = step.image
    textLabel.text = step.question
    
    setButtonsEnabled(true)
  }
  
  private func show(quiz result: QuizResultsViewModel) {
    let model = AlertModel(title: result.title,
                           message: result.text,
                           buttonText: result.buttonText) { [weak self] in
      guard let self = self else { return }
      
      self.restartGame()
    }
    
    alertPresenter.show(in: self, model: model)
  }
  
  private func restartGame() {
    self.currentQuestionIndex = 0
    self.correctAnswers = 0
    
    questionFactory?.requestNextQuestion()
  }
  
  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questionsAmount - 1 {
      statisticService.store(gameResult: GameResult(correct: correctAnswers, total: questionsAmount, date: Date()))
      
      let text = """
      Ваш результат: \(correctAnswers)/\(questionsAmount)
      Количество сыгранных квизов: \(statisticService.gamesCount)
      Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
      Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
      """
      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: text,
        buttonText: "Сыграть еще раз?")
      show(quiz: result)
    } else {
      currentQuestionIndex += 1
      
      questionFactory?.requestNextQuestion()
    }
  }
  
  private func showAnswerResult(isCorrect: Bool) {
    if isCorrect {
      correctAnswers += 1
    }
    
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      self.showNextQuestionOrResults()
      self.imageView.layer.borderWidth = 0
    }
  }
  
  private func showLoadingIndicator() {
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
  }
  
  private func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
  }
  
  private func showNetworkError(message: String) {
    hideLoadingIndicator()
    
    let model = AlertModel(title: "Ошибка",
                           message: message,
                           buttonText: "Попробовать еще раз") { [weak self] in
      guard let self = self else { return }
      
      self.currentQuestionIndex = 0
      self.correctAnswers = 0
      
      self.questionFactory?.requestNextQuestion()
    }
    
    alertPresenter.show(in: self, model: model)
  }
}
