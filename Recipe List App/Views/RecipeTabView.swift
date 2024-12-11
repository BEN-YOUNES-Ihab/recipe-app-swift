import SwiftUI

struct RecipeTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @StateObject private var favoritesViewModel = FavoriteRecipesViewModel()
    @StateObject private var recipeModel = RecipeModel()
    
    var body: some View {
        TabView {
            
            FavoritesView()
                .tabItem {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Favorites")
                    }
                }
            
            RecipeListView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("List")
                    }
                }
            
            RandomRecipeView()
                .tabItem {
                    VStack {
                        Image(systemName: "dice")
                        Text("Random Recipe")
                    }
                }
            
            RecipeGeneratorView()
                .tabItem {
                    VStack {
                        Image(systemName: "sparkle.magnifyingglass")
                        Text("Search")
                    }
                }

            
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                }
        }
        .environmentObject(recipeModel)
        .environmentObject(favoritesViewModel)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct RecipeTabView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeTabView()
    }
}
