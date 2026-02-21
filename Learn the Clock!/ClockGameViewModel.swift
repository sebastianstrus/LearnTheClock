//
//  ClockGameViewModel.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import Foundation
import SwiftUI
import Combine

final class ClockGameViewModel: ObservableObject {
    
    @Published var tasks: [ClockTask] = []
    
    private let settings: SettingsManager
    
    init(settings: SettingsManager) {
        self.settings = settings
    }
    
    func generateTasks() {
        let count = settings.exampleCount
        
        tasks = (0..<count).map { _ in
            let hour = Int.random(in: 0...23)
            let minute = Int.random(in: 0...11) * 5
            
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            
            return ClockTask(date: Calendar.current.date(from: components)!)
        }
    }
    
    func resetGame() {
        tasks.removeAll()
        generateTasks()
    }
}
