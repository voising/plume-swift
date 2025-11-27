//
//  plumeApp.swift
//  plume
//
//  Created by Guillaume on 2025. 11. 24..
//

import SwiftUI
import SwiftData

@main
struct plumeApp: App {
    @StateObject private var aiService = AIService()
    @StateObject private var authService = BiometricAuthService()
    @StateObject private var journalService: JournalService
    @StateObject private var dataService: DataService
    
    let sharedModelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Entry.self,
            Todo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            self._journalService = StateObject(wrappedValue: JournalService(modelContext: container.mainContext))
            self._dataService = StateObject(wrappedValue: DataService(modelContext: container.mainContext))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(aiService)
                    .environmentObject(journalService)
                    .environmentObject(authService)
                    .environmentObject(dataService)
                
                // Show lock screen if app lock is enabled and not unlocked
                if authService.isEnabled && !authService.isUnlocked {
                    BiometricLockScreen()
                        .environmentObject(authService)
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

