import SwiftUI

struct GeneratedRecipeDetailView: View {
    let recipeId: Int
    @State private var recipeDetail: GeneratedRecipeDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Recipe Details...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let recipe = recipeDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image de la recette
                        AsyncImage(url: URL(string: recipe.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        // Titre de la recette
                        Text(recipe.title)
                            .font(.system(size: 28, weight: .bold))
                        
                        // Temps de préparation et portions
                        HStack {
                            if let readyInMinutes = recipe.readyInMinutes {
                                Text("Preparation Time: \(readyInMinutes) mins")
                                    .font(.headline)
                            }
                            
                            if let servings = recipe.servings {
                                Text("Servings: \(servings)")
                                    .font(.headline)
                            }
                        }
                        
                        // Ingrédients
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                        ForEach(recipe.extendedIngredients, id: \.id) { ingredient in
                            Text("• \(ingredient.original)")
                        }
                        
                        // Instructions
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                        
                        // Utiliser soit instructions, soit analyzedInstructions
                        if let instructions = recipe.instructions {
                            Text(instructions)
                        } else if let analyzedInstructions = recipe.analyzedInstructions, !analyzedInstructions.isEmpty {
                            ForEach(analyzedInstructions.first?.steps ?? [], id: \.id) { step in
                                Text("\(step.number). \(step.step)")
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Failed to load recipe details")
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchRecipeDetails()
        }
    }
    
    func fetchRecipeDetails() {
        let apiKey = "b518c9ab22f94eaaabe11880a2182a9d"
        let urlString = "https://api.spoonacular.com/recipes/\(recipeId)/information?apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                defer { isLoading = false }
                
                if let error = error {
                    print("Error fetching recipe details: \(error)")
                    errorMessage = "Failed to fetch recipe details"
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let recipeInfo = try decoder.decode(GeneratedRecipeDetail.self, from: data)
                    self.recipeDetail = recipeInfo
                    print("Decoded recipe: \(recipeInfo.title)")
                } catch {
                    print("Error decoding recipe details: \(error)")
                    errorMessage = "Failed to decode recipe details: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationView {
        GeneratedRecipeDetailView(recipeId: 1)
    }
}
