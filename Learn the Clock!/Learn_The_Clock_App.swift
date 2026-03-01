//
//  Learn_The_Clock_App.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/19/26.
//

import SwiftUI

@main
struct Learn_The_Clock_Appp: App {
    
    @State private var showSplash = true
    
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var videoViewModel = VideoPlayerViewModel.shared
    
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                WelcomeContentView()
                    .environmentObject(settings)
                    .environmentObject(videoViewModel)
                    .preferredColorScheme(settings.isDarkMode ? .dark : .light)

            }
            .animation(.easeInOut(duration: 1.0), value: showSplash)
            .task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                showSplash = false
            }

        }
    }
}
