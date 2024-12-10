

import SwiftUI

struct RecipeFeaturedView: View {
    
    @EnvironmentObject var model:RecipeModel
    @State var isDetailViewShowing = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Featured Recipes")
                .bold()
                .padding(.leading)
                .padding(.top, 40)
            
                .font(.largeTitle)
            
           GeometryReader { geo in
        
        
        TabView {
            
            // Loop through each recipe
            ForEach(0..<model.recipes.count) { index in
                
                // Only show those that should be featured
                if model.recipes[index].featured == true {
                    
                    Button(action: {
                        
                        // Show the recipe detail view sheet
                       self.isDetailViewShowing = true
                        
                    }, label: {
                            
                        // Recipe card
                        ZStack {
                        Rectangle().foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            Image(model.recipes[index].image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                            
                        }
                    }
                    })
                    .sheet(isPresented: $isDetailViewShowing) {
                        // Show the Recipe Detail View
                        RecipeDetailView(recipe: model.recipes[index])
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: geo.size.width - 40, height: geo.size.height - 100, alignment: .center)
                    .cornerRadius(15)
                    .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 10, x: -5, y: 5)                }
                    
                   
                    }
                    
            
            }
            
        
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
}
           
            .padding([.leading, .bottom])
        }
            
}
    

struct RecipeFeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFeaturedView().environmentObject(RecipeModel())
    }
}
