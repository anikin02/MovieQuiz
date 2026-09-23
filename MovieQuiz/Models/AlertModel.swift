//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Данил on 18/09/2026.
//

struct AlertModel {
  let title: String
  let message: String
  let buttonText: String
  var completion: () -> Void
}
