//
//  ContentView.swift
//  RippleGeography_UI
//
//  Created by Sebastian Strus on 22/08/25.

import SwiftUI

struct LandingView: View {
    
    @Binding var showOnboarding: Bool
    
    @State var landingViewModel: LandingViewModel = .init()
    @State var viewAppeared = false
    
    @State var showText = true
    
    let animationDuration: TimeInterval = 2.5
    
    // MARK: - Views
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .padding(-44)

                VStack(alignment: .leading) {
                    GenerateLandingPages(ix: landingViewModel.currentLandingIndex)
                }
                .ignoresSafeArea()
                .onAppear() {
                    withAnimation(.snappy(duration: animationDuration / 2)) {
                        viewAppeared.toggle()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                VStack {
                    HStack(spacing: 16) {
                        ForEach(0 ..< landingViewModel.landingPages.count, id: \.self) { ix in
                            let isSelected = landingViewModel.currentLandingIndex == ix
                            let size: CGFloat = 14
                            
                            Circle()
                                .foregroundStyle(isSelected ? Color.white : .white)
                                .frame(width: isSelected ? size : size - 2, height: isSelected ? size : size - 2)
                                .opacity(isSelected ? 0.9 : 0.35)
                                .shadow(color: .black.opacity(0.9), radius: 2, x: 2, y: 2)
                                .animation(.snappy, value: landingViewModel.currentLandingIndex)
                        }
                    }
                    .padding(.bottom, 80)
                    
                }
            }
            .rippleEffect(at: landingViewModel.origin, trigger: landingViewModel.counter)
#if os(iOS)
            .toolbar(.hidden, for: .tabBar)
#endif
        }
    }
    
    
    // MARK: - Functions
    @ViewBuilder
    func GenerateLandingPages(ix: Int) -> some View {
        let landing = landingViewModel.getLanding(at: ix)
        GeometryReader { geo in
            ZStack {
                
                Image(landing.cover)
                    .resizable()
                    .opacity(landing.opacity)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: geo.size.height)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Spacer()
                    Spacer()
                    Text(landing.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 2, y: 2)
                        .multilineTextAlignment(.center)
                        .shadowed()
                        .opacity(showText ? 1 : 0)
                    
                    Text(landing.subtitle)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 2, y: 2)
                        .multilineTextAlignment(.center)
                        .shadowed()
                        .opacity(showText ? 1 : 0)
                    
                    Spacer()
                }
                .padding(.top, 80)
                .padding(.horizontal, 60)
                
//                            Image(landing.cover)
//                                .resizable()
//                                .offset(x: landing.xOffset - 4, y: landing.yOffset - 4)
//                                .opacity(0.35)
//                                .aspectRatio(contentMode: .fill)
//                                .frame(height: geo.size.height)
//                                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
//                                .clipped()
//                                .ignoresSafeArea()
//                                .mask(ViscosityView())
                
                
                
            }}
        .id(ix)
        .blur(radius: viewAppeared ? 0 : 5)
        .drawingGroup()
        .onTapGesture { location in
            landingViewModel.origin = location
            landingViewModel.counter += 2
            
            if landingViewModel.currentLandingIndex + 1 > landingViewModel.landingPages.count - 1 {
                withAnimation(.smooth(duration: animationDuration)) {
                    landingViewModel.currentLandingIndex = 0
                    
                }

                Task {
                    if showOnboarding {
                        showText = false
                    }
                    
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    withAnimation(.linear(duration: 1)) {
                        showOnboarding = false
                    }
                }
            } else {
                withAnimation(.smooth(duration: animationDuration)) {
                    landingViewModel.currentLandingIndex += 1
                }
            }
            
        }
    }
}

#Preview {
    @Previewable @State var showOnboarding = true
    LandingView(showOnboarding: $showOnboarding)
}
