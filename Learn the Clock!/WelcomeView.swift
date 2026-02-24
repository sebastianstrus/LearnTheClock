//
//  WelcomeView.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import SwiftUI
import StoreKit

struct WelcomeContentView: View {
    
    var body: some View {
        TransparentNavigationView {
            WelcomeView()
        }
        .ignoresSafeArea()
    }
}



struct WelcomeView: View {
    
    @EnvironmentObject private var settings: SettingsManager
    @EnvironmentObject private var videoViewModel: VideoPlayerViewModel
    
    @State private var showSettings = false
        
    let titleSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40
    let subtitleSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 35 : 20
    
    let startButtonWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 150 : 120
    let startButtonHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 48 : 40
    
    
    let buttonWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 320 : 280
    let buttonHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 80 : 70
    let cornerRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12
    
    var body: some View {
        ZStack {
            LoopingVideoPlayer(viewModel: videoViewModel)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.6))
            
            VStack {
                
                Spacer()
                Spacer()
                
                Group {
                    Text("Learn The Clock!")
                        .font(.system(size: titleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3)
                    
                    Text("Discover the Magic of the Clock")
                        .font(.system(size: subtitleSize, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                
                Spacer()
                Spacer()
                
                Group {
                    NavigationLink(destination: ClockGridView(settings: settings)
                            //.environmentObject(settings)
                        ) {
                            Text("Start Learning")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .glassEffect()
                        }

                        Spacer()
                        
                       
                        
                    
                    Spacer()
                }
                
            }
            .frame(maxHeight: .infinity)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
            }
        }
        .ignoresSafeArea()
    }
}




class TransparentHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationItem.hidesBackButton = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = .clear
    }
}
struct TransparentNavigationView<Content: View>: UIViewControllerRepresentable {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let rootVC = TransparentHostingController(rootView: content)
        let navController = UINavigationController(rootViewController: rootVC)
        
        updateAppearance(navController: navController)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        updateAppearance(navController: uiViewController)
    }
    
    private func updateAppearance(navController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        // Update title color based on color scheme
        let titleColor: UIColor = colorScheme == .dark ? .white.withAlphaComponent(0.9) : .black.withAlphaComponent(0.8) // You can adjust this
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        navController.navigationBar.compactAppearance = appearance
        navController.view.backgroundColor = .clear
        
        // Force update the navigation bar
        navController.navigationBar.setNeedsLayout()
        navController.navigationBar.layoutIfNeeded()
    }
}



struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
    }
}
