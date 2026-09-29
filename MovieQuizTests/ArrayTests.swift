//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Данил on 25/09/2026.
//
import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
  func testGetValueInRange() throws {
    // Given
    let nums = [1, 2, 3, 4, 5, 6, 7]
    
    // When
    let value = nums[safe: 2]
    
    // Then
    XCTAssertNotNil(value)
    XCTAssertEqual(value, 3)
  }
  
  func testGetValueOutOfRange() throws {
    // Given
    let nums = [1, 2, 3, 4, 5, 6, 7]
    
    // When
    let value = nums[safe: 30]
    
    // Then
    
    XCTAssertNil(value)
  }
}
