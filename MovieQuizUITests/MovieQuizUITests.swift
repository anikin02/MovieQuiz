//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Данил on 25/09/2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    app = XCUIApplication()
    app.launch()
    
    continueAfterFailure = false
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    
    app.terminate()
    app = nil
  }
  
  @MainActor
  func testLaunchPerformance() throws {
    measure(metrics: [XCTApplicationLaunchMetric()]) {
      XCUIApplication().launch()
    }
  }
  
  func testYesButton() {
    let yesButton = app.buttons["Yes"]
    let indexLabel = app.staticTexts["Index"]
    
    sleep(5)
    let firstPoster = app.images["Poster"]
    let firstPosterData = firstPoster.screenshot().pngRepresentation
    
    yesButton.tap()
    
    sleep(5)
    let secondPoster = app.images["Poster"]
    let secondPosterData = secondPoster.screenshot().pngRepresentation
    
    XCTAssertNotEqual(firstPosterData, secondPosterData)
    XCTAssertEqual(indexLabel.label, "2/10")
  }
  
  func testNoButton() {
    let noButton = app.buttons["No"]
    let indexLabel = app.staticTexts["Index"]
    
    sleep(15)
    let firstPoster = app.images["Poster"]
    let firstPosterData = firstPoster.screenshot().pngRepresentation
    
    noButton.tap()
    
    sleep(5)
    let secondPoster = app.images["Poster"]
    let secondPosterData = secondPoster.screenshot().pngRepresentation
    
    XCTAssertNotEqual(firstPosterData, secondPosterData)
    XCTAssertEqual(indexLabel.label, "2/10")
  }
  
  func testResultAlert() {
    sleep(5)
    
    let yesButton = app.buttons["Yes"]
    
    for _ in 0..<10 {
      yesButton.tap()
      sleep(3)
    }
    
    let alert = app.alerts["Alert"]
    
    XCTAssertTrue(alert.exists)
    XCTAssertEqual(alert.label, "Этот раунд окончен!")
    XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз?")
  }
  
  func testRestartGame() {
    sleep(5)
    
    let yesButton = app.buttons["Yes"]
    
    for _ in 0..<10 {
      yesButton.tap()
      sleep(3)
    }
    
    let alert = app.alerts["Alert"]
    
    alert.buttons.firstMatch.tap()
    
    let indexLabel = app.staticTexts["Index"]
    
    XCTAssertFalse(alert.exists)
    XCTAssertTrue(indexLabel.label == "1/10")
  }
}
