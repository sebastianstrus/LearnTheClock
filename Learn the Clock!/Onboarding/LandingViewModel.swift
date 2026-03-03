//
//  LandingViewModel.swift
//  RippleGeography_UI
//
//  Created by Sebastian Strus on 22/08/25.
//

import SwiftUI

@Observable
class LandingViewModel {
    
    // MARK: - Variables
    var landingPages: [Landing] = [
        Landing(title: "Learn The Clock!",
                subtitle: "Master telling time with fun, interactive exercises designed for every level.",
                cover: "slide1",
                xOffset: 0,
                yOffset: 5,
                opacity: 0.95),
        Landing(title: "Three Ways to Learn",
                subtitle: "Multiple-choice, time pickers, or drag the clock hands — you choose how to practice!",
                cover: "slide2",
                xOffset: -27.5,
                yOffset: -65,
                scale: 1.25),
        Landing(title: "Your Pace, Your Rules",
                subtitle: "Pick Easy, Medium, or Hard. Switch between 12 or 24-hour clocks. You're in control.",
                cover: "slide3",
                xOffset: -5,
                yOffset: -75,
                scale: 1.125),
        Landing(title: "Ready to Start?",
                subtitle: "Complete all exercises to earn your score. Challenge yourself and improve every day!",
                cover: "slide4",
                xOffset: 5,
                yOffset: -5,
                scale: 1.15)
    ]
    
    var currentLandingIndex: Int = 0
    
    //For the ripple effect
    var origin: CGPoint = .zero
    var counter: Int = 0
    
    // MARK: - Inits
    init(forTest: Bool = false) {
        
    }
    
    
    // MARK: - Functions
    func getLanding(at index: Int) -> Landing {
        return landingPages[currentLandingIndex]
    }
}


extension View {
    func shadowed() -> some View {
        
        return self
        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 5)
    }
}
