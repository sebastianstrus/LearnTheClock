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
                    
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 1.0), value: showSplash)
            .task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                showSplash = false
            }

        }
    }
}

struct SplashView: View {
    
    let titleSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                 startPoint: .top,
                                 endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("SplashIcon")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
                
                Text("Learn The Clock")
                    .font(.system(size: titleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3)
                
                Spacer()
                Spacer()
            }
        }
    }
}
