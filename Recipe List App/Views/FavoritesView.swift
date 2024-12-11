import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesViewModel: FavoriteRecipesViewModel
    @State private var isDetailViewShowing = false
    @State private var selectedRecipe: GeneratedRecipeDetail?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Favorite Recipes")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .padding(.leading)
                    .padding(.top, 40)

                if favoritesViewModel.favoriteRecipes.isEmpty {
                    EmptyStateView()
                } else {
                    RecipeCarousel()
                }
            }
            .padding([.leading, .bottom])
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isDetailViewShowing) {
            if let recipe = selectedRecipe {
                GeneratedRecipeDetailView(recipeId: recipe.id)
            }
        }
    }

    private func RecipeCarousel() -> some View {
        GeometryReader { geo in
            TabView {
                ForEach(favoritesViewModel.favoriteRecipes) { recipe in
                    RecipeCard(recipe: recipe, size: geo.size)
                        .onTapGesture {
                            self.selectedRecipe = recipe
                            self.isDetailViewShowing = true
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }

    private func RecipeCard(recipe: GeneratedRecipeDetail, size: CGSize) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: recipe.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: size.height * 0.6)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: size.height * 0.6)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }

            Text(recipe.title)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
                .frame(height: size.height * 0.2)
        }
        .frame(width: size.width - 40, height: size.height - 100)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2), radius: 10, x: 0, y: 5)
    }

    private func EmptyStateView() -> some View {
        VStack {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No favorite recipes yet.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView().environmentObject(FavoriteRecipesViewModel())
    }
}
