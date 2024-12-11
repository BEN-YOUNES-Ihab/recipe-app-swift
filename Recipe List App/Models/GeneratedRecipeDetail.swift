import Foundation

struct GeneratedRecipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
}

struct GeneratedRecipeDetail: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int?
    let servings: Int?
    let extendedIngredients: [SpoonacularIngredient]
    let instructions: String?
    let analyzedInstructions: [AnalyzedInstruction]?
}

struct SpoonacularIngredient: Identifiable, Decodable {
    let id: Int
    let name: String
    let original: String
    let amount: Double
    let unit: String
}

struct AnalyzedInstruction: Decodable {
    let name: String
    let steps: [InstructionStep]
}

struct InstructionStep: Identifiable, Decodable {
    let number: Int
    let step: String
    
    var id: Int { number }
}

struct IngredientDetail: Identifiable, Decodable {
    let id: Int
    let name: String
    let amount: String
}

struct Step: Codable, Identifiable {
    let id = UUID()
    let number: Int
    let step: String
}
