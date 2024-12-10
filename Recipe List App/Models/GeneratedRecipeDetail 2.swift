//
//  GeneratedRecipeDetail 2.swift
//  Recipe List App
//
//  Created by Saad Elmatbai on 10/12/2024.
//


struct GeneratedRecipeDetail: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let prepTime: String?
    let ingredients: [IngredientDetail]
    let directions: [String]
}

struct IngredientDetail: Identifiable, Decodable {
    let id: Int
    let name: String
    let amount: String
}
