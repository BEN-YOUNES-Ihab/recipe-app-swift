import Foundation
import SwiftUI
import os // Import the os framework for advanced logging

class FavoriteRecipesViewModel: ObservableObject {
    @Published var favoriteRecipes: [GeneratedRecipeDetail] = []
    
    // Create a logger
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FavoriteRecipesViewModel")
    
    func addToFavorites(_ recipe: GeneratedRecipeDetail) {
        if !favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            favoriteRecipes.append(recipe)
            logger.debug("Added recipe to favorites: \(recipe.id, privacy: .public)")
        } else {
            logger.debug("Recipe already in favorites: \(recipe.id, privacy: .public)")
        }
    }
    
    func removeFromFavorites(_ recipe: GeneratedRecipeDetail) {
        if let index = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favoriteRecipes.remove(at: index)
            logger.debug("Removed recipe from favorites: \(recipe.id, privacy: .public)")
        } else {
            logger.debug("Recipe not found in favorites: \(recipe.id, privacy: .public)")
        }
    }
    
    func isFavorite(_ recipe: GeneratedRecipeDetail) -> Bool {
        let isFav = favoriteRecipes.contains { $0.id == recipe.id }
        logger.debug("Checked if recipe is favorite: \(recipe.id, privacy: .public), result: \(isFav)")
        return isFav
    }
}
