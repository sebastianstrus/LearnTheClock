//
//  ContentView.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/19/26.
//

import SwiftUI
import AVFoundation

// MARK: - Dark Mode Environment Key
private struct DarkModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isDarkMode: Bool {
        get { self[DarkModeKey.self] }
        set { self[DarkModeKey.self] = newValue }
    }
}

// MARK: - Design Tokens
private struct DS {
    let dark: Bool

    var background:     Color { dark ? Color(hex: "#0F0F1A") : Color(hex: "#F5F4F0") }
    var surface:        Color { dark ? Color(hex: "#1C1C2E") : Color.white }
    var surfaceRaised:  Color { dark ? Color(hex: "#252538") : Color(hex: "#FFFFFF") }

    var primary:        Color { dark ? Color(hex: "#E8E8F0") : Color(hex: "#1A1A2E") }
    var accent:         Color { dark ? Color(hex: "#6B8AFF") : Color(hex: "#4F6EF7") }
    var accentSoft:     Color { dark ? Color(hex: "#6B8AFF").opacity(0.18) : Color(hex: "#4F6EF7").opacity(0.12) }

    var success:        Color { Color(hex: "#22C55E") }
    var successSoft:    Color { dark ? Color(hex: "#22C55E").opacity(0.20) : Color(hex: "#22C55E").opacity(0.12) }
    var error:          Color { Color(hex: "#EF4444") }
    var errorSoft:      Color { dark ? Color(hex: "#EF4444").opacity(0.22) : Color(hex: "#EF4444").opacity(0.12) }

    var textPrimary:    Color { dark ? Color(hex: "#E8E8F0") : Color(hex: "#1A1A2E") }
    var textSecondary:  Color { dark ? Color(hex: "#8B8FA8") : Color(hex: "#6B7280") }

    var border:         Color { dark ? Color(hex: "#2E2E45") : Color(hex: "#E5E7EB") }
    var separator:      Color { dark ? Color(hex: "#2E2E45") : Color(hex: "#F3F4F6") }

    var handHour:       Color { dark ? Color(hex: "#E8E8F0") : Color(hex: "#1A1A2E") }
    var handMinute:     Color { accent }
    var handDragging:   Color { Color(hex: "#F59E0B") }

    var clockFace:      [Color] { dark
        ? [Color(hex: "#2A2A3E"), Color(hex: "#222235"), Color(hex: "#1C1C2E")]
        : [Color(hex: "#D1D5DB"), Color(hex: "#E9EBF0"), Color(hex: "#F3F4F6")] }
    var clockInner:     [Color] { dark
        ? [Color(hex: "#282838"), Color(hex: "#1E1E30")]
        : [Color.white, Color(hex: "#F8F9FB")] }
    var clockRim:       [Color] { dark
        ? [Color(hex: "#3A3A55"), Color(hex: "#505070"), Color(hex: "#2E2E48"), Color(hex: "#484868"), Color(hex: "#3A3A55"), Color(hex: "#505070"), Color(hex: "#3A3A55")]
        : [Color(hex: "#C8CDD6"), Color(hex: "#F0F2F5"), Color(hex: "#A8AEBB"), Color(hex: "#ECEEF2"), Color(hex: "#B8BDC8"), Color(hex: "#F0F2F5"), Color(hex: "#C8CDD6")] }
    var tickQuarter:    Color { dark ? Color(hex: "#E8E8F0") : Color(hex: "#111827") }
    var tickHour:       Color { dark ? Color(hex: "#B0B4CC") : Color(hex: "#374151") }
    var tickMinute:     Color { dark ? Color(hex: "#4A4A65") : Color(hex: "#9CA3AF") }
    var numberQuarter:  Color { dark ? Color(hex: "#E8E8F0") : Color(hex: "#111827") }
    var numberHour:     Color { dark ? Color(hex: "#B0B4CC") : Color(hex: "#374151") }

    var jewelOuter:     [Color] { dark
        ? [Color(hex: "#4A4A65"), Color(hex: "#2E2E48"), Color(hex: "#1C1C30")]
        : [Color(hex: "#E8EAED"), Color(hex: "#9BA3AF"), Color(hex: "#6B7280")] }

    func display(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    func mono(_ size: CGFloat) -> Font    { .system(size: size, weight: .medium,   design: .monospaced) }
    func body(_ size: CGFloat) -> Font    { .system(size: size, weight: .regular,  design: .default) }

    let radiusCard:  CGFloat = 16
    let radiusSmall: CGFloat = 10
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double(rgb         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Clock Grid View
struct ClockGridView: View {

    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: ClockGameViewModel
    @State private var showCoins = false
    @State private var shouldShowNameAlert = false
    @State private var userName = ""
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentTaskIndex: Int = 0

    init(settings: SettingsManager) {
        _viewModel = StateObject(wrappedValue: ClockGameViewModel(settings: settings))
    }

    private var dark: Bool { viewModel.settings.isDarkMode }
    private var ds:   DS   { DS(dark: dark) }

    var body: some View {
        ZStack {
            if dark {
                LinearGradient(
                    colors: [
                        Color(hex: "#0D0D1F"),
                        Color(hex: "#12122A"),
                        Color(hex: "#0A0A18")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.72, green: 0.88, blue: 0.95),
                        Color(red: 0.55, green: 0.78, blue: 0.90),
                        Color(red: 0.40, green: 0.68, blue: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 28) {
                if !viewModel.tasks.isEmpty {
                    ProgressHeaderView(
                        current: currentTaskIndex + 1,
                        completed: currentTaskIndex,
                        total: viewModel.tasks.count
                    )
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                }

                if !viewModel.tasks.isEmpty && currentTaskIndex < viewModel.tasks.count {
                    let task = viewModel.tasks[currentTaskIndex]
                    Group {
                        switch task.type {
                        case .multipleChoice:
                            MultipleChoiceTaskView(
                                task: task,
                                viewModel: viewModel,
                                onTaskSolved: handleTaskSolved
                            )
                        case .timePicker:
                            TimePickerTaskView(
                                task: task,
                                viewModel: viewModel,
                                onTaskSolved: handleTaskSolved
                            )
                        case .interactiveHands:
                            ClockTaskView(
                                task: task,
                                viewModel: viewModel,
                                onTaskSolved: handleTaskSolved
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(currentTaskIndex)
                }

                Spacer()
            }

            if showCoins {
                FallingCoinsView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .environment(\.isDarkMode, dark)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Set the Time")
                    .bold()
                    .foregroundColor(dark ? Color(hex: "#E8E8F0") : .black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(dark ? Color(hex: "#12122A") : .clear, for: .navigationBar)
        .toolbarBackground(dark ? .visible : .automatic, for: .navigationBar)
        .onAppear {
            viewModel.resetGame()
            currentTaskIndex = 0
            showCoins = false
            startTimer()
        }
        .onDisappear { stopTimer() }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showCoins)
        .animation(.easeInOut(duration: 0.3), value: currentTaskIndex)
        .alert("Congratulations!".localized + "\n" + elapsedTime.formattedTime, isPresented: $shouldShowNameAlert) {
            TextField("Nickname".localized, text: $userName)
            Button("Save".localized) { saveResultAndShowVictory() }
            Button("Skip".localized, role: .cancel) { }
        } message: {
            Text("Enter your nickname to save the result".localized)
        }
        .onChange(of: showCoins) {
            if showCoins {
                stopTimer()
                shouldShowNameAlert = true
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .flipsForRightToLeftLayoutDirection(true)
                    }
                    .foregroundColor(ds.accent)
                }
            }
            
            if viewModel.settings.isTimerOn {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(elapsedTime.formattedTimeWithMilliseconds)
                        .font(Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .medium, design: .monospaced))
                        .foregroundColor(viewModel.settings.isTimerOn ? ds.accent : .clear)
                        .padding(.horizontal, 10)
                }
            }
        }
    }

    private func handleTaskSolved() {
        let nextIndex = currentTaskIndex + 1
        if nextIndex < viewModel.tasks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                currentTaskIndex = nextIndex
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showCoins = true
            }
        }
    }

    private func startTimer() {
        guard startTime == nil else { return }
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let s = startTime { elapsedTime = Date().timeIntervalSince(s) }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    private func stopTimer() { timer?.invalidate(); timer = nil }

    private func saveResultAndShowVictory() {
        let difficulty = DifficultyLevel(rawValue: viewModel.settings.difficultyLevel) ?? .medium
        viewModel.settings.saveGameResult(
            name: userName.isEmpty ? "Anonymous" : userName,
            difficulty: difficulty,
            exampleCount: viewModel.settings.exampleCount,
            time: elapsedTime,
            is24HourClock: viewModel.settings.is24HourClock
        )
    }
}

// MARK: - Progress Header
struct ProgressHeaderView: View {
    let current: Int
    let completed: Int
    let total: Int

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    var progress: CGFloat { CGFloat(completed) / CGFloat(total) }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(ds.accent)
                            .frame(width: 24, height: 24)
                        Text("\(current)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Text("of \(total)")
                        .font(ds.display(14))
                        .foregroundColor(ds.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(ds.accentSoft)
                        .overlay(Capsule().strokeBorder(ds.accent.opacity(0.2), lineWidth: 1))
                )

                Spacer()

                HStack(spacing: 3) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(ds.accent)
                    Text("%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(ds.accent.opacity(0.7))
                        .offset(y: 1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ds.accentSoft)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ds.accent.opacity(0.2), lineWidth: 1))
                )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ds.border)
                        .frame(height: 10)
                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.black.opacity(dark ? 0.0 : 0.04), lineWidth: 1))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [ds.accent, ds.accent.opacity(0.75)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(10, geo.size.width * progress), height: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(color: ds.accent.opacity(0.45), radius: 5, x: 0, y: 2)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)

                    if progress > 0.02 {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 5, height: 5)
                            .shadow(color: ds.accent, radius: 4)
                            .offset(x: max(5, geo.size.width * progress - 8), y: 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                    }
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: ds.radiusCard)
                .fill(ds.surface)
                .shadow(color: dark ? Color.black.opacity(0.4) : Color(hex: "#1A1A2E").opacity(0.07), radius: 12, x: 0, y: 4)
                .shadow(color: Color.black.opacity(dark ? 0.3 : 0.04), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - PART 1: Multiple Choice Task View
struct MultipleChoiceTaskView: View {
    let task: ClockTask
    @ObservedObject var viewModel: ClockGameViewModel
    var onTaskSolved: () -> Void

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    @State private var options: [Date] = []
    @State private var selectedOption: Date?
    @State private var isCorrect = false
    @State private var wrongSelection: Date?
    @State private var audioPlayer: AVAudioPlayer?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private let optionLabels = ["A", "B", "C", "D", "E", "F"]

    private var difficulty: DifficultyLevel {
        DifficultyLevel(rawValue: viewModel.settings.difficultyLevel) ?? .medium
    }

    var body: some View {
        VStack(spacing: 20) {
            instructionChip
            staticClockView
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 4)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    optionButton(label: optionLabels[index], date: option)
                }
            }
            statusView
        }
        .padding(24)
        .background(ds.surface)
        .cornerRadius(ds.radiusCard)
        .shadow(
            color: isCorrect ? ds.success.opacity(0.15) : Color.black.opacity(dark ? 0.35 : 0.06),
            radius: isCorrect ? 20 : 10, y: 4
        )
        .animation(.easeInOut(duration: 0.3), value: isCorrect)
        .onAppear {
            options = viewModel.generateMultipleChoiceOptions(for: task)
        }
    }

    private var instructionChip: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [ds.accentSoft, ds.accent.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(LinearGradient(colors: [ds.accent.opacity(0.45), ds.accent.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)

            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(ds.accent.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ds.accent)
                }
                Rectangle().fill(ds.accent.opacity(0.2)).frame(width: 1, height: 28)
                Text("What time is shown?")
                    .font(ds.display(16))
                    .foregroundColor(ds.textPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .fixedSize()
        .shadow(color: ds.accent.opacity(0.18), radius: 12, x: 0, y: 4)
    }

    private var staticClockView: some View {
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let h = Double(components.hour! % 12)
        let m = Double(components.minute!)
        let hourAngle   = h * 30 + m / 60 * 30
        let minuteAngle = m * 6

        return StaticClockView(
            hourAngle: hourAngle,
            minuteAngle: minuteAngle,
            isCorrect: isCorrect,
            showHourNumbers: difficulty != .hard
        )
    }

    private func optionButton(label: String, date: Date) -> some View {
        let isSelected = selectedOption.map { Calendar.current.dateComponents([.hour, .minute], from: $0) }
            == Calendar.current.dateComponents([.hour, .minute], from: date)
        let isWrong = wrongSelection.map { Calendar.current.dateComponents([.hour, .minute], from: $0) }
            == Calendar.current.dateComponents([.hour, .minute], from: date)
        let isCorrectOption = Calendar.current.dateComponents([.hour, .minute], from: date)
            == Calendar.current.dateComponents([.hour, .minute], from: task.date)

        var bgColor:     Color = ds.surface
        var borderColor: Color = ds.border
        var textColor:   Color = ds.textPrimary

        if isCorrect && isCorrectOption {
            bgColor     = ds.successSoft
            borderColor = ds.success
            textColor   = ds.success
        } else if isWrong {
            bgColor     = ds.errorSoft
            borderColor = ds.error
            textColor   = ds.error
        } else if isSelected {
            bgColor     = ds.accentSoft
            borderColor = ds.accent
            textColor   = ds.accent
        }

        return Button {
            guard !isCorrect else { return }
            handleSelection(date)
        } label: {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(textColor.opacity(0.6))
                Text(viewModel.formattedTime(date))
                    .font(ds.mono(15))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: ds.radiusSmall)
                    .fill(bgColor)
                    .overlay(RoundedRectangle(cornerRadius: ds.radiusSmall).strokeBorder(borderColor, lineWidth: 1.5))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isWrong)
        .animation(.easeInOut(duration: 0.2), value: isCorrect)
    }

    private var statusView: some View {
        Group {
            if isCorrect {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(ds.success)
                    Text("correct_exclamation")
                        .font(ds.display(16))
                        .foregroundColor(ds.success)
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(ds.successSoft)
                .clipShape(Capsule())
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                Label("Pick the time shown on the clock", systemImage: "hand.point.up.left")
                    .font(ds.body(15))
                    .foregroundColor(ds.textSecondary)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCorrect)
    }

    private func handleSelection(_ date: Date) {
        selectedOption = date
        let correct = Calendar.current.dateComponents([.hour, .minute], from: date)
            == Calendar.current.dateComponents([.hour, .minute], from: task.date)

        if correct {
            isCorrect = true
            wrongSelection = nil
            playSuccessSound()
            viewModel.markTaskSolved(task)
            onTaskSolved()
        } else {
            wrongSelection = date
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                wrongSelection = nil
                selectedOption = nil
            }
        }
    }

    private func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "stars", withExtension: "m4a") else { return }
        do { audioPlayer = try AVAudioPlayer(contentsOf: url); audioPlayer?.play() }
        catch { print("Sound error: \(error)") }
    }
}

// MARK: - PART 2: Time Picker Task View
struct TimePickerTaskView: View {
    let task: ClockTask
    @ObservedObject var viewModel: ClockGameViewModel
    var onTaskSolved: () -> Void

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    @State private var selectedHour: Int = 12
    @State private var selectedMinute: Int = 0
    @State private var isCorrect = false
    @State private var showError = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var shakeTrigger: CGFloat = 0

    private var difficulty: DifficultyLevel {
        DifficultyLevel(rawValue: viewModel.settings.difficultyLevel) ?? .medium
    }

    private var hourRange: [Int] {
        viewModel.settings.is24HourClock ? Array(0...23) : Array(1...12)
    }

    private var minuteValues: [Int] {
        switch difficulty {
        case .easy:   return [0, 15, 30, 45]
        case .medium: return Array(stride(from: 0, through: 55, by: 5))
        case .hard:   return Array(0...59)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            instructionChip
            staticClockView
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 4)

            if !isCorrect {
                pickerRow
            }

            Group {
                if isCorrect {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(ds.success)
                        Text("correct_exclamation")
                            .font(ds.display(16))
                            .foregroundColor(ds.success)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(ds.successSoft)
                    .clipShape(Capsule())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    VStack(spacing: 8) {
                        Button(action: checkAnswer) {
                            Text("Confirm")
                                .font(ds.display(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: ds.radiusSmall)
                                        .fill(ds.accent)
                                        .shadow(color: ds.accent.opacity(0.4), radius: 8, y: 3)
                                )
                        }
                        .buttonStyle(.plain)
                        .modifier(ShakeEffect(animatableData: shakeTrigger))
                        .animation(.default, value: shakeTrigger)

//                        if showError {
//                            Text("Not quite — try again!")
//                                .font(ds.body(14))
//                                .foregroundColor(ds.error)
//                                .transition(.scale(scale: 0.9).combined(with: .opacity))
//                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCorrect)
        }
        .padding(24)
        .background(ds.surface)
        .cornerRadius(ds.radiusCard)
        .shadow(
            color: isCorrect ? ds.success.opacity(0.15) : Color.black.opacity(dark ? 0.35 : 0.06),
            radius: isCorrect ? 20 : 10, y: 4
        )
        .animation(.easeInOut(duration: 0.3), value: isCorrect)
        .onAppear { initPickerValues() }
    }

    private var instructionChip: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [ds.accentSoft, ds.accent.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(LinearGradient(colors: [ds.accent.opacity(0.45), ds.accent.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)

            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(ds.accent.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ds.accent)
                }
                Rectangle().fill(ds.accent.opacity(0.2)).frame(width: 1, height: 28)
                Text("What time is it?")
                    .font(ds.display(16))
                    .foregroundColor(ds.textPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .fixedSize()
        .shadow(color: ds.accent.opacity(0.18), radius: 12, x: 0, y: 4)
    }

    private var staticClockView: some View {
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let h = Double(components.hour! % 12)
        let m = Double(components.minute!)
        let hourAngle   = h * 30 + m / 60 * 30
        let minuteAngle = m * 6

        return StaticClockView(
            hourAngle: hourAngle,
            minuteAngle: minuteAngle,
            isCorrect: isCorrect,
            showHourNumbers: difficulty != .hard
        )
    }

    private var pickerRow: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Hour")
                    .font(ds.body(12))
                    .foregroundColor(ds.textSecondary)
                Picker("Hour", selection: $selectedHour) {
                    ForEach(hourRange, id: \.self) { h in
                        Text(String(format: viewModel.settings.is24HourClock ? "%02d" : "%d", h))
                            .tag(h)
                            .foregroundColor(ds.textPrimary)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 120)
                .clipped()
                .colorScheme(dark ? .dark : .light)
            }

            Text(":")
                .font(ds.mono(32))
                .foregroundColor(ds.textPrimary)
                .padding(.bottom, 2)

            VStack(spacing: 4) {
                Text("Minute")
                    .font(ds.body(12))
                    .foregroundColor(ds.textSecondary)
                Picker("Minute", selection: $selectedMinute) {
                    ForEach(minuteValues, id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                            .foregroundColor(ds.textPrimary)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 120)
                .clipped()
                .colorScheme(dark ? .dark : .light)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: ds.radiusSmall)
                .fill(dark ? Color(hex: "#1E1E30") : ds.accentSoft)
                .overlay(RoundedRectangle(cornerRadius: ds.radiusSmall).strokeBorder(ds.accent.opacity(0.2), lineWidth: 1))
        )
    }

    private func initPickerValues() {
        selectedHour   = hourRange.filter { !acceptableHours.contains($0) }.randomElement() ?? hourRange.first!
        selectedMinute = minuteValues.filter { $0 != correctMinute }.randomElement() ?? minuteValues.first!
    }

    private var acceptableHours: Set<Int> {
        let h = Calendar.current.dateComponents([.hour], from: task.date).hour!
        if viewModel.settings.is24HourClock {
            let mirror = (h + 12) % 24
            return Set([h, mirror].filter { hourRange.contains($0) })
        }
        let h12 = h % 12
        return [h12 == 0 ? 12 : h12]
    }

    private var correctMinute: Int {
        Calendar.current.dateComponents([.minute], from: task.date).minute!
    }

    private func checkAnswer() {
        let minuteOk: Bool
        switch difficulty {
        case .easy:   minuteOk = abs(selectedMinute - correctMinute) < 8
        case .medium: minuteOk = abs(selectedMinute - correctMinute) < 5 || abs(selectedMinute - correctMinute) == 0
        case .hard:   minuteOk = selectedMinute == correctMinute
        }
        let hourOk = acceptableHours.contains(selectedHour)
        if hourOk && minuteOk {
            isCorrect = true
            showError = false
            playSuccessSound()
            viewModel.markTaskSolved(task)
            onTaskSolved()
        } else {
            showError = true
            
            // HAPTIC
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // SHAKE
            shakeTrigger += 1
        }
    }

    private func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "stars", withExtension: "m4a") else { return }
        do { audioPlayer = try AVAudioPlayer(contentsOf: url); audioPlayer?.play() }
        catch { print("Sound error: \(error)") }
    }
}

// MARK: - Static Clock View
struct StaticClockView: View {
    let hourAngle: Double
    let minuteAngle: Double
    var isCorrect: Bool
    var showHourNumbers: Bool = true

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = size / 2

            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: ds.clockFace,
                        center: .init(x: 0.38, y: 0.32),
                        startRadius: size * 0.02,
                        endRadius: size * 0.54
                    ))
                    .shadow(color: Color.black.opacity(dark ? 0.6 : 0.28), radius: 24, x: 6, y: 10)
                    .shadow(color: (dark ? Color(hex: "#6B8AFF") : Color.white).opacity(dark ? 0.08 : 0.9), radius: 6, x: -3, y: -3)

                Circle()
                    .stroke(AngularGradient(colors: ds.clockRim, center: .center), lineWidth: size * 0.045)
                    .padding(size * 0.012)

                Circle()
                    .stroke(
                        isCorrect
                        ? LinearGradient(colors: [ds.success, ds.success.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [
                            dark ? Color(hex: "#3A3A55") : Color(hex: "#9BA3AF"),
                            dark ? Color(hex: "#505070") : Color(hex: "#CBD0D8")
                          ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
                    .padding(size * 0.048)
                    .shadow(color: isCorrect ? ds.success.opacity(0.4) : .clear, radius: 6)

                Circle()
                    .fill(RadialGradient(
                        colors: ds.clockInner,
                        center: .init(x: 0.45, y: 0.4),
                        startRadius: 0,
                        endRadius: size * 0.48
                    ))
                    .padding(size * 0.065)

                ForEach(0..<60) { tick in
                    let isHour    = tick % 5  == 0
                    let isQuarter = tick % 15 == 0
                    let tickW: CGFloat = isQuarter ? 3.5 : isHour ? 2.5 : 1.2
                    let tickH: CGFloat = isQuarter ? 16  : isHour ? 14  : 7
                    let faceRadius     = center - size * 0.065
                    let tickCenterDist = faceRadius - tickH / 2
                    Rectangle()
                        .fill(isQuarter ? ds.tickQuarter : isHour ? ds.tickHour : ds.tickMinute)
                        .opacity(isQuarter ? 1.0 : isHour ? 0.85 : 0.5)
                        .frame(width: tickW, height: tickH)
                        .cornerRadius(tickW / 2)
                        .offset(y: -tickCenterDist)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }

                if showHourNumbers {
                    ForEach(1...12, id: \.self) { n in
                        let isQuarter = n % 3 == 0
                        Text("\(n)")
                            .font(.system(size: isQuarter ? size * 0.082 : size * 0.068,
                                          weight: isQuarter ? .bold : .semibold, design: .rounded))
                            .foregroundColor(isQuarter ? ds.numberQuarter : ds.numberHour)
                            .position(numberPosition(for: Double(n) * 30, size: size))
                    }
                }

                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                let handScale: CGFloat = isPad ? 2.0 : 1.0

                TaperedClockHand(length: center * 0.62, tailLength: center * 0.15,
                                 tipWidth: 3.5 * handScale, baseWidth: 12 * handScale,
                                 angle: hourAngle, fillColor: ds.handHour, isDragging: false)
                TaperedClockHand(length: center * 0.84, tailLength: center * 0.17,
                                 tipWidth: 2 * handScale, baseWidth: 8 * handScale,
                                 angle: minuteAngle, fillColor: ds.handMinute, isDragging: false)

                CenterJewel(size: size * 0.075)
            }
        }
    }

    private func numberPosition(for angle: Double, size: CGFloat) -> CGPoint {
        let r = size * 0.330
        let rad = (angle - 90) * .pi / 180
        return CGPoint(x: size/2 + r * CGFloat(cos(rad)), y: size/2 + r * CGFloat(sin(rad)))
    }
}

// MARK: - PART 3: Interactive Hands Task View
struct ClockTaskView: View {
    let task: ClockTask
    @ObservedObject var viewModel: ClockGameViewModel
    var onTaskSolved: () -> Void

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect = false
    @State private var audioPlayer: AVAudioPlayer?

    private var difficulty: DifficultyLevel {
        DifficultyLevel(rawValue: viewModel.settings.difficultyLevel) ?? .medium
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [ds.accentSoft, ds.accent.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(LinearGradient(colors: [ds.accent.opacity(0.45), ds.accent.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)

                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(ds.accent.opacity(0.15)).frame(width: 32, height: 32)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ds.accent)
                    }
                    Rectangle().fill(ds.accent.opacity(0.2)).frame(width: 1, height: 28)
                    Text(formatted(time: task.date))
                        .font(ds.mono(30))
                        .foregroundColor(ds.textPrimary)
                        .tracking(1.5)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
            .fixedSize()
            .shadow(color: ds.accent.opacity(0.18), radius: 12, x: 0, y: 4)
            .shadow(color: Color.black.opacity(dark ? 0.3 : 0.05), radius: 4, x: 0, y: 2)

            AnalogClockView(
                hourAngle: $hourAngle,
                minuteAngle: $minuteAngle,
                isCorrect: isCorrect,
                isLocked: isCorrect,
                showHourNumbers: difficulty != .hard,
                onDragEnded: { check() }
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 4)

            Group {
                if isCorrect {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(ds.success)
                        Text("Correct")
                            .font(ds.display(16))
                            .foregroundColor(ds.success)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(ds.successSoft)
                    .clipShape(Capsule())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Label("Drag the hands to match the time", systemImage: "hand.draw")
                        .font(ds.body(16))
                        .foregroundColor(ds.textSecondary)
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCorrect)
        }
        .padding(24)
        .background(ds.surface)
        .cornerRadius(ds.radiusCard)
        .shadow(
            color: isCorrect ? ds.success.opacity(0.15) : Color.black.opacity(dark ? 0.35 : 0.06),
            radius: isCorrect ? 20 : 10, y: 4
        )
        .animation(.easeInOut(duration: 0.3), value: isCorrect)
    }

    private func check() {
        guard !isCorrect else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let targetHourAngle   = (Double(components.hour! % 12) * 30) + (Double(components.minute!) / 60 * 30)
        let targetMinuteAngle = Double(components.minute!) * 6
        let tolerance = viewModel.toleranceForDifficulty()
        let wasCorrect = isCorrect
        isCorrect = angularDifference(hourAngle, targetHourAngle) < tolerance.hour &&
                    angularDifference(minuteAngle, targetMinuteAngle) < tolerance.minute
        if isCorrect && !wasCorrect {
            playSuccessSound()
            viewModel.markTaskSolved(task)
            onTaskSolved()
        }
    }

    private func angularDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }

    private func formatted(time: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = viewModel.settings.is24HourClock ? "HH:mm" : "hh:mm"
        return f.string(from: time)
    }

    private func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "stars", withExtension: "m4a") else { return }
        do { audioPlayer = try AVAudioPlayer(contentsOf: url); audioPlayer?.play() }
        catch { print("Sound error: \(error)") }
    }
}

// MARK: - Analog Clock View (interactive)
struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool
    var isLocked: Bool
    var showHourNumbers: Bool = true
    var onDragEnded: (() -> Void)?

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    @State private var draggingHand: DraggingHand?
    enum DraggingHand { case hour, minute }

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = size / 2

            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: ds.clockFace,
                        center: .init(x: 0.38, y: 0.32),
                        startRadius: size * 0.02,
                        endRadius: size * 0.54
                    ))
                    .shadow(color: Color.black.opacity(dark ? 0.6 : 0.28), radius: 24, x: 6, y: 10)
                    .shadow(color: Color.black.opacity(dark ? 0.4 : 0.12), radius: 8, x: 2, y: 4)
                    .shadow(color: ds.accent.opacity(dark ? 0.15 : 0.10), radius: 30, x: 0, y: 8)
                    .shadow(color: (dark ? Color(hex: "#6B8AFF") : Color.white).opacity(dark ? 0.08 : 0.9), radius: 6, x: -3, y: -3)

                Circle()
                    .stroke(AngularGradient(colors: ds.clockRim, center: .center), lineWidth: size * 0.045)
                    .padding(size * 0.012)

                Circle()
                    .stroke(
                        isCorrect
                        ? LinearGradient(colors: [ds.success, ds.success.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [
                            dark ? Color(hex: "#3A3A55") : Color(hex: "#9BA3AF"),
                            dark ? Color(hex: "#505070") : Color(hex: "#CBD0D8")
                          ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
                    .padding(size * 0.048)
                    .shadow(color: isCorrect ? ds.success.opacity(0.4) : .clear, radius: 6)

                Circle()
                    .fill(RadialGradient(
                        colors: ds.clockInner,
                        center: .init(x: 0.45, y: 0.4),
                        startRadius: 0,
                        endRadius: size * 0.48
                    ))
                    .padding(size * 0.065)

                ForEach(0..<60) { tick in
                    let isHour    = tick % 5  == 0
                    let isQuarter = tick % 15 == 0
                    let tickW: CGFloat = isQuarter ? 3.5 : isHour ? 2.5 : 1.2
                    let tickH: CGFloat = isQuarter ? 16  : isHour ? 14  : 7
                    let faceRadius     = center - size * 0.065
                    let tickCenterDist = faceRadius - tickH / 2
                    Rectangle()
                        .fill(isQuarter ? ds.tickQuarter : isHour ? ds.tickHour : ds.tickMinute)
                        .opacity(isQuarter ? 1.0 : isHour ? 0.85 : 0.5)
                        .frame(width: tickW, height: tickH)
                        .cornerRadius(tickW / 2)
                        .offset(y: -tickCenterDist)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }

                if showHourNumbers {
                    ForEach(1...12, id: \.self) { n in
                        let isQuarter = n % 3 == 0
                        Text("\(n)")
                            .font(.system(size: isQuarter ? size * 0.082 : size * 0.068,
                                          weight: isQuarter ? .bold : .semibold, design: .rounded))
                            .foregroundColor(isQuarter ? ds.numberQuarter : ds.numberHour)
                            .position(numberPosition(for: Double(n) * 30, size: size))
                    }
                }

                Circle()
                    .stroke(Color.black.opacity(dark ? 0.0 : 0.04), lineWidth: 6)
                    .padding(size * 0.065)
                    .blur(radius: 4)

                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                let handScale: CGFloat = isPad ? 2.0 : 1.0

                TaperedClockHand(
                    length: center * 0.62, tailLength: center * 0.15,
                    tipWidth: 3.5 * handScale, baseWidth: 12 * handScale,
                    angle: hourAngle,
                    fillColor: draggingHand == .hour ? ds.handDragging : ds.handHour,
                    isDragging: draggingHand == .hour
                )
                TaperedClockHand(
                    length: center * 0.84, tailLength: center * 0.17,
                    tipWidth: 2 * handScale, baseWidth: 8 * handScale,
                    angle: minuteAngle,
                    fillColor: draggingHand == .minute ? ds.handDragging : ds.handMinute,
                    isDragging: draggingHand == .minute
                )

                CenterJewel(size: size * 0.075)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isLocked else { return }
                        let cp = CGPoint(x: size / 2, y: size / 2)
                        if draggingHand == nil {
                            draggingHand = closestHand(touch: value.startLocation, center: cp,
                                                       hourLen: center * 0.62, minuteLen: center * 0.84)
                        }
                        let angle = angleFrom(value.location, center: cp)
                        if draggingHand == .hour   { hourAngle   = angle }
                        if draggingHand == .minute { minuteAngle = angle }
                    }
                    .onEnded { _ in draggingHand = nil; onDragEnded?() }
            )
        }
    }

    private func numberPosition(for angle: Double, size: CGFloat) -> CGPoint {
        let r = size * 0.330
        let rad = (angle - 90) * .pi / 180
        return CGPoint(x: size/2 + r * CGFloat(cos(rad)), y: size/2 + r * CGFloat(sin(rad)))
    }

    private func angleFrom(_ point: CGPoint, center: CGPoint) -> Double {
        let v = CGVector(dx: point.x - center.x, dy: point.y - center.y)
        let deg = atan2(v.dy, v.dx) * 180 / .pi + 90
        return deg < 0 ? deg + 360 : deg
    }

    private func closestHand(touch: CGPoint, center: CGPoint, hourLen: CGFloat, minuteLen: CGFloat) -> DraggingHand {
        func tip(_ angle: Double, _ len: CGFloat) -> CGPoint {
            let r = (angle - 90) * .pi / 180
            return CGPoint(x: center.x + len * CGFloat(cos(r)), y: center.y + len * CGFloat(sin(r)))
        }
        func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
        return dist(touch, tip(hourAngle, hourLen)) < dist(touch, tip(minuteAngle, minuteLen)) ? .hour : .minute
    }
}

// MARK: - Tapered Clock Hand
struct TaperedClockHand: View {
    let length: CGFloat
    let tailLength: CGFloat
    let tipWidth: CGFloat
    let baseWidth: CGFloat
    let angle: Double
    let fillColor: Color
    let isDragging: Bool

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let tip   = CGPoint(x: cx, y: cy - length)
            let baseL = CGPoint(x: cx - baseWidth / 2, y: cy)
            let baseR = CGPoint(x: cx + baseWidth / 2, y: cy)
            let tailL = CGPoint(x: cx - tipWidth / 2, y: cy + tailLength)
            let tailR = CGPoint(x: cx + tipWidth / 2, y: cy + tailLength)

            var path = Path()
            path.move(to: tip); path.addLine(to: baseR); path.addLine(to: tailR)
            path.addLine(to: tailL); path.addLine(to: baseL); path.closeSubpath()
            ctx.fill(path, with: .color(fillColor))

            var sheen = Path()
            sheen.move(to: tip)
            sheen.addLine(to: CGPoint(x: cx - baseWidth * 0.3, y: cy))
            sheen.addLine(to: CGPoint(x: cx - tipWidth * 0.2, y: cy + tailLength * 0.6))
            ctx.fill(sheen, with: .color(.white.opacity(0.25)))
            ctx.stroke(path, with: .color(fillColor.opacity(0.6)), lineWidth: 0.5)
        }
        .shadow(color: fillColor.opacity(isDragging ? 0.5 : 0.25), radius: isDragging ? 10 : 5, x: 1, y: 2)
        .rotationEffect(.degrees(angle))
        .scaleEffect(isDragging ? 1.06 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isDragging)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: fillColor)
    }
}

// MARK: - Center Jewel
struct CenterJewel: View {
    let size: CGFloat

    @Environment(\.isDarkMode) private var dark
    private var ds: DS { DS(dark: dark) }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(dark ? 0.5 : 0.18))
                .frame(width: size + 4, height: size + 4)
                .blur(radius: 3)
                .offset(y: 1.5)
            Circle()
                .fill(RadialGradient(
                    colors: ds.jewelOuter,
                    center: .init(x: 0.35, y: 0.3),
                    startRadius: 0,
                    endRadius: size * 0.6
                ))
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(dark ? 0.4 : 0.85), Color.white.opacity(0)],
                    center: .init(x: 0.3, y: 0.25),
                    startRadius: 0,
                    endRadius: size * 0.35
                ))
                .frame(width: size, height: size)
            Circle()
                .fill(dark ? Color(hex: "#6B8AFF").opacity(0.6) : Color(hex: "#374151"))
                .frame(width: size * 0.22, height: size * 0.22)
        }
    }
}


struct FallingCoinsView: View {
    @State private var coins: [Coin] = []
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                ForEach(coins) { coin in
                    Image("coin")
                        .resizable()
                        .frame(width: coin.size, height: coin.size)
                        .rotationEffect(.degrees(coin.rotation))
                        .position(x: coin.x, y: coin.y)
                        .onAppear {
                            animateCoinDrop(coin, screenHeight: geometry.size.height)
                        }
                }
            }
            .onAppear {
                startCoinRain(screenWidth: geometry.size.width)
                SoundManager.shared.playSound(named: "coin_sound", loop: true)
            }
            .onDisappear {
                stopCoinRain()
                SoundManager.shared.stopSound()
            }
        }
    }
    
    // MARK: - Coin Rain
    func startCoinRain(screenWidth: CGFloat) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            let newCoin = Coin(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: -150,
                size: CGFloat.random(in: 50...200),
                rotation: Double.random(in: 0...400),
                duration: Double.random(in: 0.7...3)
            )
            coins.append(newCoin)
        }
    }
    
    func animateCoinDrop(_ coin: Coin, screenHeight: CGFloat) {
        if let index = coins.firstIndex(where: { $0.id == coin.id }) {
            withAnimation(.linear(duration: coin.duration)) {
                coins[index].y = screenHeight + 50
            }

            // Remove coin after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + coin.duration) {
                coins.removeAll { $0.id == coin.id }
            }
        }
    }
    
    func stopCoinRain() {
        timer?.invalidate()
        timer = nil
    }
}

struct Coin: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var rotation: Double
    var duration: Double
}
