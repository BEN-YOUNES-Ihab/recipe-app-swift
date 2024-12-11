import SwiftUI


struct GeneratedRecipeDetailView: View {
    let recipeId: Int
    @EnvironmentObject private var favoritesViewModel: FavoriteRecipesViewModel
    @State private var recipeDetail: GeneratedRecipeDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isFavorite = false
    
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
                        AsyncImage(url: URL(string: recipe.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        HStack {
                            Text(recipe.title)
                                .font(.system(size: 28, weight: .bold))
                            
                            Spacer()
                            
                            Button(action: {
                                if isFavorite {
                                    favoritesViewModel.removeFromFavorites(recipe)
                                } else {
                                    favoritesViewModel.addToFavorites(recipe)
                                }
                                isFavorite.toggle()
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .imageScale(.large)
                            }
                        }
                        
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
                        
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                        ForEach(recipe.extendedIngredients, id: \.id) { ingredient in
                            Text("• \(ingredient.original)")
                        }
                        
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                        
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
            updateFavoriteStatus()
        }
    }
    
    private func updateFavoriteStatus() {
        if let recipe = recipeDetail {
            isFavorite = favoritesViewModel.isFavorite(recipe)
        }
    }
    
    func fetchRecipeDetails() {
        let apiKey = "8ee679c936ea48eab97da024f396f433"
        let urlString = "https://api.spoonacular.com/recipes/\(recipeId)/information?apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                defer {
                    isLoading = false
                    updateFavoriteStatus()
                }
                
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
                    updateFavoriteStatus()
                } catch {
                    print("Error decoding recipe details: \(error)")
                    errorMessage = "Failed to decode recipe details: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
//test
#Preview {
    NavigationView {
        GeneratedRecipeDetailView(recipeId: 1)
    }
}
