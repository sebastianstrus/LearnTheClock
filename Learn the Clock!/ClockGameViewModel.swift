//
//  ClockGameViewModel.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Task Type
enum ClockTaskType {
    case multipleChoice   // Part 1: See clock, pick correct time from 6 options
    case timePicker       // Part 2: See clock, use hour/minute pickers to identify time
    case interactiveHands // Part 3: See time label, drag hands to match (original mechanic)
}

// MARK: - Models
struct ClockTask: Identifiable {
    let id = UUID()
    let date: Date
    let type: ClockTaskType

    init(date: Date, type: ClockTaskType = .interactiveHands) {
        self.date = date
        self.type = type
    }
}

// MARK: - ViewModel
final class ClockGameViewModel: ObservableObject {

    @Published var tasks: [ClockTask] = []
    @Published var solvedTasks: [UUID: Bool] = [:]

    let settings: SettingsManager

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

    // MARK: - Task Generation
    func generateTasks() {
        let count = settings.exampleCount
        let difficulty = DifficultyLevel(rawValue: settings.difficultyLevel) ?? .medium
        let third = count / 3

        tasks = (0..<count).map { index in
            let taskType: ClockTaskType
            if index < third {
                taskType = .multipleChoice
            } else if index < third * 2 {
                taskType = .timePicker
            } else {
                taskType = .interactiveHands
            }
            return makeTask(difficulty: difficulty, type: taskType)
        }
    }

    private func makeTask(difficulty: DifficultyLevel, type: ClockTaskType) -> ClockTask {
        let hour = settings.is24HourClock ? Int.random(in: 0...23) : Int.random(in: 1...12)

        let minute: Int
        switch difficulty {
        case .easy:   minute = [0, 15, 30, 45].randomElement()!
        case .medium: minute = Int.random(in: 0...11) * 5
        case .hard:   minute = Int.random(in: 0...59)
        }

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return ClockTask(date: Calendar.current.date(from: components)!, type: type)
    }

    func resetGame() {
        tasks.removeAll()
        solvedTasks.removeAll()
        generateTasks()
    }

    func toleranceForDifficulty() -> (hour: Double, minute: Double) {
        switch DifficultyLevel(rawValue: settings.difficultyLevel) ?? .easy {
        case .easy:   return (hour: 12.0, minute: 6.0)
        case .medium: return (hour: 6.0,  minute: 3.0)
        case .hard:   return (hour: 3.0,  minute: 1.5)
        }
    }

    // MARK: - Multiple Choice Options
    /// Returns 6 shuffled Date options where exactly one matches the task's time.
    func generateMultipleChoiceOptions(for task: ClockTask) -> [Date] {
        let difficulty = DifficultyLevel(rawValue: settings.difficultyLevel) ?? .medium
        var options: [Date] = [task.date]
        let calendar = Calendar.current
        let correctComponents = calendar.dateComponents([.hour, .minute], from: task.date)
        let correctHour = correctComponents.hour!
        let correctMinute = correctComponents.minute!

        while options.count < 6 {
            let hour: Int
            let minute: Int

            switch difficulty {
            case .easy:
                // Different hours, only quarter-hour minutes
                hour = settings.is24HourClock
                    ? (correctHour + Int.random(in: 1...11)) % 24
                    : ((correctHour - 1 + Int.random(in: 1...11)) % 12) + 1
                minute = [0, 15, 30, 45].randomElement()!

            case .medium:
                // Mix: same hour/different minute OR different hour
                if Bool.random() {
                    hour = correctHour
                    var m = Int.random(in: 0...11) * 5
                    if m == correctMinute { m = (m + 5) % 60 }
                    minute = m
                } else {
                    hour = settings.is24HourClock
                        ? (correctHour + Int.random(in: 1...5)) % 24
                        : ((correctHour - 1 + Int.random(in: 1...5)) % 12) + 1
                    minute = Int.random(in: 0...11) * 5
                }

            case .hard:
                // Close distractors: nearby minute or ±1 hour
                if Bool.random() {
                    hour = correctHour
                    let delta = [-15, -10, -5, 5, 10, 15].randomElement()!
                    minute = ((correctMinute + delta) % 60 + 60) % 60
                } else {
                    let hourDelta = Bool.random() ? 1 : -1
                    hour = settings.is24HourClock
                        ? ((correctHour + hourDelta) % 24 + 24) % 24
                        : (((correctHour - 1 + hourDelta) % 12) + 12) % 12 + 1
                    minute = correctMinute
                }
            }

            // Reject duplicates
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            guard let candidate = calendar.date(from: components) else { continue }
            let isDuplicate = options.contains {
                let ec = calendar.dateComponents([.hour, .minute], from: $0)
                return ec.hour == hour && ec.minute == minute
            }
            if !isDuplicate { options.append(candidate) }
        }

        return options.shuffled()
    }

    // MARK: - Helpers
    func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = settings.is24HourClock ? "HH:mm" : "hh:mm a"
        return f.string(from: date)
    }
}
