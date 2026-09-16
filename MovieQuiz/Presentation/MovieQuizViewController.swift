import UIKit

final class MovieQuizViewController: UIViewController {
  // MARK: - IBOutlet
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet weak var noButton: UIButton!
  @IBOutlet weak var yesButton: UIButton!
  
  // MARK: - Properties
  private let questions: [QuizQuestion] = QuizQuestion.mocks
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureImageView()
    
    let currentQuestion = questions[currentQuestionIndex]
    show(quiz: convert(model: currentQuestion))
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
    let currentQuestion = questions[currentQuestionIndex]
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
      image: UIImage(named: model.image) ?? UIImage(),
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
  }
  
  private func show(quiz step: QuizStepViewModel) {
    counterLabel.text = step.questionNumber
    imageView.image = step.image
    textLabel.text = step.question
    
    setButtonsEnabled(true)
  }
  
  private func show(quiz result: QuizResultsViewModel) {
    let alert = UIAlertController(
      title: result.title,
      message: result.text,
      preferredStyle: .alert)
    
    let action = getRestartGameAction(with: result)
    
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
  }
  
  private func getRestartGameAction(with result: QuizResultsViewModel) -> UIAlertAction {
    let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
      self.currentQuestionIndex = 0
      self.correctAnswers = 0
      
      let firstQuestion = self.questions[self.currentQuestionIndex]
      let viewModel = self.convert(model: firstQuestion)
      self.show(quiz: viewModel)
    }
    
    return action
  }
  
  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questions.count - 1 {
      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: "Ваш результат: \(correctAnswers)/\(questions.count)",
        buttonText: "Сыграть еще раз?")
      show(quiz: result)
    } else {
      currentQuestionIndex += 1
      
      let nextQuestion = questions[currentQuestionIndex]
      let viewModel = convert(model: nextQuestion)
      show(quiz: viewModel)
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
}
