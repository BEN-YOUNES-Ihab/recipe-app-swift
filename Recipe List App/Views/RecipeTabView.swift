

import SwiftUI

struct RecipeTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        TabView {
            RecipeFeaturedView()
                .tabItem {
                    VStack {
                        Image(systemName: "star.fill")
                        Text("Featured")
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
        .environmentObject(RecipeModel())
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

// Vue pour générer des recettes


struct RecipeTabView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeTabView()
    }
}
