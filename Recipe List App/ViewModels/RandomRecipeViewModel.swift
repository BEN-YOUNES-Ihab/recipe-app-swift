import Foundation
import SwiftUI

class RandomRecipeViewModel: ObservableObject {
    @Published var randomRecipe: GeneratedRecipeDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "b518c9ab22f94eaaabe11880a2182a9d" // Replace with your actual API key
    
    func fetchRandomRecipe() {
        isLoading = true
        errorMessage = nil
        
        // Construct the URL for a random recipe
        guard let url = URL(string: "https://api.spoonacular.com/recipes/random?number=1&apiKey=\(apiKey)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        // Use URLSession's dataTask with completion handler
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Dispatch to main queue for UI updates
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    // Decode the random recipe response
                    let decodedResponse = try JSONDecoder().decode(RandomRecipeResponse.self, from: data)
                    if let recipe = decodedResponse.recipes.first {
                        self?.randomRecipe = recipe
                    } else {
                        self?.errorMessage = "No recipes found"
                    }
                } catch {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }
        
        // Start the network request
        task.resume()
    }
}

// Add this struct to decode the random recipe response
struct RandomRecipeResponse: Decodable {
    let recipes: [GeneratedRecipeDetail]
}
