//
//  WellDayApp.swift
//  WellDay
//
//  Main app entry point
//

import SwiftUI

@main
struct WellDayApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var mealsViewModel = MealsViewModel()
    @StateObject private var recipesViewModel = RecipesViewModel()
    
    init() {
        // Initialize with sample data if needed
        do {
            try StorageService.shared.initializeWithSampleData()
        } catch {
            print("Error initializing sample data: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(mealsViewModel)
                .environmentObject(recipesViewModel)
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            RecipeHubView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserViewModel())
            .environmentObject(MealsViewModel())
            .environmentObject(RecipesViewModel())
    }
}
