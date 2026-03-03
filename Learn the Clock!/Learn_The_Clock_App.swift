//
//  Learn_The_Clock_App.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/19/26.
//

import SwiftUI

@main
struct Learn_The_Clock_Appp: App {
    
    @AppStorage("shouldShowOnboarding") private var shouldShowOnboarding = true
    
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var videoViewModel = VideoPlayerViewModel.shared
    
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                WelcomeContentView()
                    .environmentObject(settings)
                    .environmentObject(videoViewModel)
                    .preferredColorScheme(settings.isDarkMode ? .dark : .light)
                    .transition(.opacity)
                
                if shouldShowOnboarding {
                    LandingView(showOnboarding: $shouldShowOnboarding)
                        .transition(.opacity)
                        .zIndex(1)
                }
                
            }

        }
    }
}
