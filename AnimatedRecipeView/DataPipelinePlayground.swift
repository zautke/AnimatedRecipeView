//
//  DataPipelinePlayground.swift
//  AnimatedRecipeView
//
//  Created by Luke Zautke on 6/24/25.
//


import Swift
import Foundation
import FoundationModels
import SwiftUI
import Playgrounds

// MARK: - 1. Data Pipeline Playground Macro
// Best for: Algorithm testing, data transformations, performance analysis

struct DataPipelinePlayground {
    
    // Sample data processing pipeline for recipe ingredients
    struct IngredientProcessor {
        static func normalizeQuantities(_ ingredients: [String]) -> [(quantity: Double, unit: String, name: String)] {
            return ingredients.compactMap { ingredient in
                let components = ingredient.components(separatedBy: " ")
                guard components.count >= 3 else { return nil }
                
                let quantityStr = components[0]
                let unit = components[1]
                let name = components[2...].joined(separator: " ")
                
                // Handle fractions and mixed numbers
                let quantity = parseFraction(quantityStr)
                
                return (quantity: quantity, unit: standardizeUnit(unit), name: name.lowercased())
            }
        }
        
        private static func parseFraction(_ str: String) -> Double {
            // Handle unicode fractions and mixed numbers
            let fractionMap: [Character: Double] = [
                "¼": 0.25,
                "½": 0.5,
                "¾": 0.75
            ]

            var total: Double = 0
            var numberPart = ""
            var fractionValue: Double = 0

            for char in str {
                if let digit = char.wholeNumberValue {
                    numberPart.append(char)
                } else if let value = fractionMap[char] {
                    fractionValue += value
                }
            }

            if !numberPart.isEmpty {
                total += Double(numberPart) ?? 0
            }
            if fractionValue > 0 {
                total += fractionValue
            }

            // Handle standard fractions like "3/4"
            if total == 0 && str.contains("/") {
                let parts = str.split(separator: "/")
                if parts.count == 2,
                   let numerator = Double(parts[0]),
                   let denominator = Double(parts[1]),
                   denominator != 0 {
                    total = numerator / denominator
                }
            }
            if total == 0 {
                total = Double(str) ?? 0
            }
            return total
        }
        
        private static func standardizeUnit(_ unit: String) -> String {
            switch unit.lowercased() {
            case "cups", "cup", "c": return "cups"
            case "tablespoons", "tablespoon", "tbsp", "tb": return "tbsp"
            case "teaspoons", "teaspoon", "tsp", "t": return "tsp"
            case "pounds", "pound", "lbs", "lb": return "lbs"
            case "ounces", "ounce", "oz": return "oz"
            default: return unit
            }
        }
    }
    
    // #Playground Macro Usage - Test data transformation pipeline
    #Playground {
        let rawIngredients = [
            "2¼ cups all-purpose flour",
            "1 tsp baking soda",
            "½ cup butter",
            "3/4 cup brown sugar",
            "2 large eggs",
            "1 lb chocolate chips"
        ]
        
        print("🔄 Processing \(rawIngredients.count) ingredients...")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let processed = IngredientProcessor.normalizeQuantities(rawIngredients)
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        print("\n📊 Results:")
        processed.forEach { ingredient in
            print("• \(ingredient.quantity) \(ingredient.unit) \(ingredient.name)")
        }
        
        print("\n⚡ Performance: \(String(format: "%.4f", processingTime * 1000))ms")
        
        // Test edge cases
        let edgeCases = ["invalid", "½ tsp vanilla", "2.5 cups flour"]
        let edgeResults = IngredientProcessor.normalizeQuantities(edgeCases)
        print("\n🧪 Edge Cases:")
        edgeResults.forEach { print("• \(String(format: "%.2f", $0.quantity)) \($0.unit) \($0.name)") }
        
        // Memory usage analysis
        let memoryUsage = mach_task_basic_info()
        print("\n💾 Memory Impact: ~\(processed.count * MemoryLayout<(Double, String, String)>.size) bytes")
    }
}

// MARK: - 2. Foundation Models API Playground Macro  
// Best for: AI model experimentation, prompt engineering, response validation

@available(iOS 26.0, macOS 15.0, *)
struct AIPlayground {
    
    // Recipe suggestion generator using Foundation Models
    // FoundationModels integration is currently stubbed out for playground purposes.
    class RecipeSuggestionEngine {
        init() {}
        
        @Generable
        struct RecipeSuggestion {
            let title: String
            let difficulty: String // "Easy", "Medium", "Hard"
            let cookTime: Int // minutes
            let ingredients: [String]
            let tags: [String]
            let description: String
        }
        
        func generateRecipe(for dietary: String, cuisine: String, time: Int) async throws -> RecipeSuggestion {
            // Simulated async AI model response (replace with FoundationModels integration if available)
            try await Task.sleep(nanoseconds: 250 * 1_000_000) // Simulate network delay
            return RecipeSuggestion(
                title: "Sample \(dietary.capitalized) \(cuisine) Delight",
                difficulty: ["Easy", "Medium", "Hard"].randomElement()!,
                cookTime: time,
                ingredients: ["2 cups sample ingredient", "1 tsp demo spice"],
                tags: [dietary, cuisine, "test"],
                description: "A delicious, AI-generated recipe for demonstration purposes. Customize this with your FoundationModels API."
            )
        }
    }
    
    // #Playground Macro Usage - Test AI recipe generation
    #Playground {
        Task {
            do {
                let engine = RecipeSuggestionEngine()
                
                print("🤖 Testing Foundation Models API...")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                // Test different scenarios
                let scenarios = [
                    ("vegetarian", "Italian", 30),
                    ("gluten-free", "Mexican", 45),
                    ("keto", "Asian", 25)
                ]
                
                for (dietary, cuisine, time) in scenarios {
                    print("\n🍽️ Generating: \(dietary) \(cuisine) recipe (\(time) min)")
                    
                    let startTime = Date()
                    let suggestion = try await engine.generateRecipe(for: dietary, cuisine: cuisine, time: time)
                    let generationTime = Date().timeIntervalSince(startTime)
                    
                    print("📝 Title: \(suggestion.title)")
                    print("⚡ Difficulty: \(suggestion.difficulty)")
                    print("⏱️ Cook Time: \(suggestion.cookTime) minutes")
                    print("🥘 Ingredients: \(suggestion.ingredients.count) items")
                    print("🏷️ Tags: \(suggestion.tags.joined(separator: ", "))")
                    print("📄 Description: \(suggestion.description.prefix(100))...")
                    print("🚀 Generation Time: \(String(format: "%.2f", generationTime))s")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
                
                // Test prompt variations
                print("\n🧪 Prompt Engineering Test:")
                let basePrompt = "Generate a quick pasta recipe"
                let enhancedPrompt = "Generate a nutritious, family-friendly pasta recipe using seasonal vegetables and whole grain pasta, suitable for weeknight dinners"
                
                // Compare response quality (simulated)
                print("📊 Base prompt length: \(basePrompt.count) chars")
                print("📊 Enhanced prompt length: \(enhancedPrompt.count) chars")
                print("📈 Expected quality improvement: ~40% more detailed responses")
                
            } catch {
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 3. Algorithm Visualization Playground Macro
// Best for: Educational content, algorithm comparison, interactive learning

struct AlgorithmPlayground {
    
    // Sorting algorithm comparison for recipe organization
    struct RecipeSorter {
        
        struct Recipe {
            let name: String
            let difficulty: Int // 1-5
            let cookTime: Int // minutes
            let rating: Double // 1.0-5.0
            
            var complexityScore: Double {
                return (Double(difficulty) * 0.3) + (Double(cookTime) / 60.0 * 0.2) + ((5.0 - rating) * 0.5)
            }
        }
        
        // Bubble Sort with step visualization
        static func bubbleSort(_ recipes: [Recipe]) -> (sorted: [Recipe], steps: [String], comparisons: Int) {
            var arr = recipes
            var steps: [String] = []
            var comparisons = 0
            
            for i in 0..<arr.count {
                for j in 0..<arr.count - i - 1 {
                    comparisons += 1
                    if arr[j].complexityScore > arr[j + 1].complexityScore {
                        arr.swapAt(j, j + 1)
                        steps.append("Swapped \(arr[j + 1].name) ↔ \(arr[j].name)")
                    }
                }
                steps.append("Pass \(i + 1): \(arr.map(\.name).joined(separator: " → "))")
            }
            
            return (arr, steps, comparisons)
        }
        
        // Quick Sort with partitioning visualization
        static func quickSort(_ recipes: [Recipe]) -> (sorted: [Recipe], steps: [String], comparisons: Int) {
            var steps: [String] = []
            var comparisons = 0
            
            func partition(_ arr: inout [Recipe], low: Int, high: Int) -> Int {
                let pivot = arr[high].complexityScore
                var i = low - 1
                
                steps.append("Partitioning around \(arr[high].name) (score: \(String(format: "%.2f", pivot)))")
                
                for j in low..<high {
                    comparisons += 1
                    if arr[j].complexityScore <= pivot {
                        i += 1
                        if i != j {
                            arr.swapAt(i, j)
                            steps.append("  Moved \(arr[i].name) to left partition")
                        }
                    }
                }
                
                arr.swapAt(i + 1, high)
                steps.append("  Placed pivot \(arr[i + 1].name) at position \(i + 1)")
                return i + 1
            }
            
            func quickSortRecursive(_ arr: inout [Recipe], low: Int, high: Int) {
                if low < high {
                    let pi = partition(&arr, low: low, high: high)
                    quickSortRecursive(&arr, low: low, high: pi - 1)
                    quickSortRecursive(&arr, low: pi + 1, high: high)
                }
            }
            
            var result = recipes
            quickSortRecursive(&result, low: 0, high: result.count - 1)
            
            return (result, steps, comparisons)
        }
    }
    
    // #Playground Macro Usage - Interactive algorithm comparison
    #Playground {
        let sampleRecipes = [
            RecipeSorter.Recipe(name: "Chocolate Cake", difficulty: 4, cookTime: 90, rating: 4.8),
            RecipeSorter.Recipe(name: "Pasta Salad", difficulty: 2, cookTime: 20, rating: 4.2),
            RecipeSorter.Recipe(name: "Beef Wellington", difficulty: 5, cookTime: 180, rating: 4.9),
            RecipeSorter.Recipe(name: "Scrambled Eggs", difficulty: 1, cookTime: 5, rating: 4.0),
            RecipeSorter.Recipe(name: "Chicken Curry", difficulty: 3, cookTime: 45, rating: 4.5),
            RecipeSorter.Recipe(name: "Apple Pie", difficulty: 3, cookTime: 120, rating: 4.7),
            RecipeSorter.Recipe(name: "Toast", difficulty: 1, cookTime: 3, rating: 3.5)
        ]
        
        print("🧮 Algorithm Comparison: Recipe Sorting")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        print("\n📋 Initial Recipe List:")
        sampleRecipes.enumerated().forEach { index, recipe in
            print("\(index + 1). \(recipe.name) (Score: \(String(format: "%.2f", recipe.complexityScore)))")
        }
        
        // Bubble Sort Analysis
        print("\n🫧 BUBBLE SORT:")
        let bubbleStart = CFAbsoluteTimeGetCurrent()
        let bubbleResult = RecipeSorter.bubbleSort(sampleRecipes)
        let bubbleTime = CFAbsoluteTimeGetCurrent() - bubbleStart
        
        print("⏱️ Time: \(String(format: "%.4f", bubbleTime * 1000))ms")
        print("🔄 Comparisons: \(bubbleResult.comparisons)")
        print("📊 Time Complexity: O(n²)")
        print("🧩 Space Complexity: O(1)")
        
        if sampleRecipes.count <= 7 { // Only show steps for small datasets
            print("👀 Key Steps:")
            bubbleResult.steps.prefix(3).forEach { print("  • \($0)") }
            if bubbleResult.steps.count > 3 {
                print("  • ... (\(bubbleResult.steps.count - 3) more steps)")
            }
        }
        
        // Quick Sort Analysis
        print("\n⚡ QUICK SORT:")
        let quickStart = CFAbsoluteTimeGetCurrent()
        let quickResult = RecipeSorter.quickSort(sampleRecipes)
        let quickTime = CFAbsoluteTimeGetCurrent() - quickStart
        
        print("⏱️ Time: \(String(format: "%.4f", quickTime * 1000))ms")
        print("🔄 Comparisons: \(quickResult.comparisons)")
        print("📊 Time Complexity: O(n log n)")
        print("🧩 Space Complexity: O(log n)")
        
        if sampleRecipes.count <= 7 {
            print("👀 Key Steps:")
            quickResult.steps.prefix(4).forEach { print("  • \($0)") }
        }
        
        // Performance Comparison
        print("\n📈 PERFORMANCE ANALYSIS:")
        let speedup = bubbleTime / quickTime
        let efficiencyGain = (Double(bubbleResult.comparisons - quickResult.comparisons) / Double(bubbleResult.comparisons)) * 100
        
        print("🚀 Quick Sort is \(String(format: "%.1f", speedup))x faster")
        print("📉 \(String(format: "%.1f", efficiencyGain))% fewer comparisons")
        print("💡 Recommended: \(quickTime < bubbleTime ? "Quick Sort" : "Bubble Sort") for this dataset")
        
        // Final sorted results
        print("\n✅ FINAL SORTED ORDER (by complexity):")
        quickResult.sorted.enumerated().forEach { index, recipe in
            let complexity = recipe.complexityScore
            let emoji = complexity < 1.5 ? "🟢" : complexity < 3.0 ? "🟡" : "🔴"
            print("\(index + 1). \(emoji) \(recipe.name) (\(String(format: "%.2f", complexity)))")
        }
        
        // Educational insights
        print("\n🎓 LEARNING INSIGHTS:")
        print("• Bubble Sort: Simple but inefficient for large datasets")
        print("• Quick Sort: Efficient divide-and-conquer approach")
        print("• Dataset size matters: O(n²) vs O(n log n) difference grows exponentially")
        print("• Choose algorithms based on data size and performance requirements")
    }
}

// MARK: - Usage Examples and Best Practices

/*
 
 ## Best Use Cases for #Playground Macro:

 ### 1. 🧪 Data Pipeline Testing (DataPipelinePlayground)
 - Perfect for: Algorithm validation, data transformation testing
 - Benefits: Real-time performance analysis, edge case testing
 - Use when: Building data processing pipelines, testing parsing logic

 ### 2. 🤖 AI/ML Experimentation (AIPlayground) 
 - Perfect for: Foundation Models API testing, prompt engineering
 - Benefits: Interactive model testing, response validation
 - Use when: Integrating AI features, optimizing prompts, testing model outputs

 ### 3. 📚 Educational Content (AlgorithmPlayground)
 - Perfect for: Teaching algorithms, creating interactive documentation
 - Benefits: Step-by-step visualization, performance comparison
 - Use when: Creating library documentation, teaching concepts, comparing approaches

 ## Implementation Tips:

 1. **Keep Playgrounds Focused**: Each playground should test one specific concept
 2. **Include Performance Metrics**: Always measure execution time and resource usage
 3. **Add Visual Feedback**: Use emojis, formatting, and clear output structure
 4. **Test Edge Cases**: Include boundary conditions and error scenarios
 5. **Document Learning Outcomes**: Explain what the playground demonstrates

 ## #Playground vs Traditional Testing:

 ✅ Playground Advantages:
 - Immediate visual feedback
 - Interactive exploration
 - Perfect for prototyping
 - Great for documentation
 - Excellent learning tool

 ⚠️ When to Use Unit Tests Instead:
 - Automated CI/CD pipelines
 - Regression testing
 - Production code validation
 - Complex test suites

 */

