
import SwiftUI
import Foundation

class SpoonacularRecipeViewModel: ObservableObject {
    @Published var recipes: [SpoonacularRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "b518c9ab22f94eaaabe11880a2182a9d"
    
    func fetchRecipes(query: String = "") {
        isLoading = true
        errorMessage = nil
        
        // Construct URL with optional query
        var urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey)&number=10&addRecipeInformation=true"
        
        if !query.isEmpty {
            urlString += "&query=\(query.urlEncoded)"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
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
                    let decodedResponse = try JSONDecoder().decode(SpoonacularRecipeResponse.self, from: data)
                    self?.recipes = decodedResponse.results
                } catch {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

// Spoonacular Recipe Model
struct SpoonacularRecipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let servings: Int?
    let readyInMinutes: Int?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let aggregateLikes: Int?
    let healthScore: Double?
    let dishTypes: [String]?
    let extendedIngredients: [SpoonacularIngredient]?
    let instructions: String?
    let analyzedInstructions: [AnalyzedInstruction]?
}

// Updated RecipeListView to use Spoonacular ViewModel
struct RecipeListView: View {
    @StateObject private var viewModel = SpoonacularRecipeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Spoonacular Recipes")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                // Search Bar
                SearchBar(text: $searchText, onCommit: { query in
                    viewModel.fetchRecipes(query: query)
                })
                .padding(.horizontal)
                
                // Loading and Error Handling
                if viewModel.isLoading {
                    ProgressView("Loading Recipes...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.recipes) { recipe in
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
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Fetch initial recipes when view appears
                viewModel.fetchRecipes()
            }
        }
    }
}

// Row View for Spoonacular Recipes
struct SpoonacularRecipeRowView: View {
    let recipe: SpoonacularRecipe
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    if let servings = recipe.servings {
                        Text("\(servings) servings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let readyInMinutes = recipe.readyInMinutes {
                        Text("• \(readyInMinutes) mins")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// Spoonacular Recipe Detail View
struct SpoonacularRecipeDetailView: View {
    let recipe: SpoonacularRecipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Recipe Image
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .frame(height: 250)
                }
                
                // Recipe Details
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Recipe Meta Information
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
                    
                    if let ingredients = recipe.extendedIngredients {
                        ForEach(ingredients, id: \.id) { ingredient in
                            Text("• \(ingredient.original)")
                        }
                    }
                    
                    // Instructions Section
                    Text("Instructions")
                        .font(.headline)
                    
                    if let instructions = recipe.instructions {
                        Text(instructions)
                    } else if let analyzedInstructions = recipe.analyzedInstructions {
                        ForEach(analyzedInstructions[0].steps, id: \.number) { step in
                            Text("\(step.number). \(step.step)")
                                .padding(.bottom, 5)
                        }
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Updated SearchBar to include onCommit handler
struct SearchBar: View {
    @Binding var text: String
    var onCommit: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Recipes", text: $text, onCommit: {
                onCommit(text)
            })
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Response structure for Spoonacular API
struct SpoonacularRecipeResponse: Decodable {
    let results: [SpoonacularRecipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}

// Extension to help with URL encoding
extension String {
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView().environmentObject(RecipeModel())
    }
}
