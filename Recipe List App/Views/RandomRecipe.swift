//
//  RandomRecipe.swift
//  Recipe List App
//
//  Created by Saad Elmatbai on 10/12/2024.
//

import SwiftUI

struct RandomRecipeView: View {
    @StateObject private var viewModel = RandomRecipeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Generating Random Recipe...")
                } else if let recipe = viewModel.randomRecipe {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            // Recipe Image
                            AsyncImage(url: URL(string: recipe.image)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 250)
                            
                            // Recipe Title
                            Text(recipe.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Recipe Details
                            HStack {
                                if let readyInMinutes = recipe.readyInMinutes {
                                    Label("\(readyInMinutes) mins", systemImage: "clock")
                                }
                                if let servings = recipe.servings {
                                    Label("\(servings) servings", systemImage: "person.2")
                                }
                            }
                            .foregroundColor(.secondary)
                            
                            // Ingredients Section
                            Text("Ingredients")
                                .font(.headline)
                            ForEach(recipe.extendedIngredients) { ingredient in
                                Text("• \(ingredient.original)")
                            }
                            
                            // Instructions Section
                            Text("Instructions")
                                .font(.headline)
                            
                            // Prefer analyzedInstructions if available, otherwise use instructions
                            if let analyzedInstructions = recipe.analyzedInstructions, !analyzedInstructions.isEmpty {
                                ForEach(analyzedInstructions[0].steps) { step in
                                    Text("\(step.number). \(step.step)")
                                        .padding(.bottom, 5)
                                }
                            } else if let instructions = recipe.instructions {
                                Text(instructions)
                            }
                        }
                        .padding()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Button("Generate Random Recipe") {
                        viewModel.fetchRandomRecipe()
                    }
                }
            }
            .navigationTitle("Random Recipe")
            .navigationBarItems(trailing:
                Button("Regenerate") {
                    viewModel.fetchRandomRecipe()
                }
            )
        }
    }
}

#Preview {
    RandomRecipeView()
}
