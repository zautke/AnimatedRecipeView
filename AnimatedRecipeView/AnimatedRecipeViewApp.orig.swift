////
////  AnimatedRecipeViewApp.swift
////  AnimatedRecipeView
////
////  Created by Luke Zautke on 6/23/25.
////
//
//import SwiftUI
//import SwiftData
//
//@main
//struct AnimatedRecipeViewApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}
