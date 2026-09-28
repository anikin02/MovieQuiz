import UIKit

final class MovieQuizViewController: UIViewController {
  // MARK: - IBOutlet
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet weak var noButton: UIButton!
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Properties
  private var alertPresenter = AlertPresenter()
  private var presenter: MovieQuizPresenter!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureImageView()
    
    showLoadingIndicator()
    
    presenter = MovieQuizPresenter(viewController: self)
  }
  
  // MARK: - IBAction
  @IBAction private func yesButtonClicked(_ sender: Any) {
    setButtonsEnabled(false)
    presenter.yesButtonClicked()
  }
  
  @IBAction private func noButtonClicked(_ sender: Any) {
    setButtonsEnabled(false)
    presenter.noButtonClicked()
  }
  
  // MARK: - Public Methods
  func show(quiz step: QuizStepViewModel) {
    counterLabel.text = step.questionNumber
    imageView.layer.borderColor = UIColor.clear.cgColor
    imageView.image = UIImage(data: step.image) ?? UIImage()
    textLabel.text = step.question
    
    setButtonsEnabled(true)
  }
  
  func show(quiz result: QuizResultsViewModel) {
    let model = AlertModel(title: result.title,
                           message: result.text,
                           buttonText: result.buttonText) { [weak self] in
      guard let self = self else { return }
      
      presenter.restartGame()
    }
    
    alertPresenter.show(in: self, model: model)
  }
  
  func highlightImageBorder(isCorrectAnswer: Bool) {
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
  }
  
  func showLoadingIndicator() {
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
  }
  
  func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
  }
  
  func showNetworkError(message: String) {
    hideLoadingIndicator()
    let alertTitle = "Ошибка"
    let buttonText = "Попробовать еще раз"
    let model = AlertModel(title: alertTitle,
                           message: message,
                           buttonText: buttonText) { [weak self] in
      guard let self = self else { return }
      
      presenter.restartGame()
    }
    
    alertPresenter.show(in: self, model: model)
  }
  
  // MARK: - Private Methods
  private func configureImageView() {
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 20
  }
  
  private func setButtonsEnabled(_ isEnabled: Bool) {
    noButton.isEnabled = isEnabled
    yesButton.isEnabled = isEnabled
  }
}
