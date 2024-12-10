import SwiftUI

struct RecipeGeneratorView: View {
    @State private var ingredients: String = ""
    @State private var generatedRecipes: [GeneratedRecipe] = []
    @FocusState private var isFocused: Bool
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recipe Generator")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Create delicious meals from your ingredients")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Ingredients")
                        .font(.headline)
                    
                    TextField("e.g. chicken, tomatoes, rice", text: $ingredients)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                Button(action: generateRecipes) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("Generate Recipes")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .disabled(ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                
                if !generatedRecipes.isEmpty {
                    List(generatedRecipes) { recipe in
                        NavigationLink(destination: GeneratedRecipeDetailView(recipeId: recipe.id)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(recipe.title)
                                    .font(.headline)
                                
                                if let imageURL = URL(string: recipe.image) {
                                    AsyncImage(url: imageURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 150)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                } else if !isLoading && !ingredients.isEmpty {
                    Text("No recipes found. Try different ingredients.")
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    func generateRecipes() {
        isLoading = true
        generatedRecipes = []
        
        let formattedIngredients = ingredients
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: ",")
        
        guard !formattedIngredients.isEmpty else {
            isLoading = false
            return
        }
        
        let apiKey = "b518c9ab22f94eaaabe11880a2182a9d" // Remplacez par votre clé API Spoonacular
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(formattedIngredients)&number=5&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            defer { isLoading = false }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let recipes = try JSONDecoder().decode([GeneratedRecipe].self, from: data)
                DispatchQueue.main.async {
                    self.generatedRecipes = recipes
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }
}

#Preview {
    RecipeGeneratorView()
}
