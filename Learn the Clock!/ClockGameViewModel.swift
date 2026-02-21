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
    @Published var solvedTasks: [UUID: Bool] = [:]
    
    private let settings: SettingsManager
    
    init(settings: SettingsManager) {
        self.settings = settings
    }
    
    func markTaskSolved(_ task: ClockTask) {
            solvedTasks[task.id] = true
        }

        func isTaskSolved(_ task: ClockTask) -> Bool {
            solvedTasks[task.id] ?? false
        }

        func allTasksSolved() -> Bool {
            tasks.allSatisfy { isTaskSolved($0) }
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
    
    func toleranceForDifficulty() -> (hour: Double, minute: Double) {
            switch DifficultyLevel(rawValue: settings.difficultyLevel) ?? .easy {
            case .easy:
                    return (hour: 12.0, minute: 6.0)   // smaller, still forgiving
                case .medium:
                    return (hour: 6.0, minute: 3.0)    // default
                case .hard:
                    return (hour: 3.0, minute: 1.5)    // precise
            }
        }
}
