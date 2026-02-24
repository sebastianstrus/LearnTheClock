//
//  ContentView.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/19/26.
//

import SwiftUI
import AVFoundation

// MARK: - Models
struct ClockTask: Identifiable {
    let id = UUID()
    let date: Date
}


// MARK: - Clock Grid View
struct ClockGridView: View {
    
    @StateObject private var viewModel: ClockGameViewModel
    @State private var showCoins = false
    @State private var shouldShowNameAlert = false
    @State private var userName = ""
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    init(settings: SettingsManager) {
        _viewModel = StateObject(wrappedValue: ClockGameViewModel(settings: settings))
    }
    
    private var columnSpacing: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 16 : 4
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: columnSpacing),
            GridItem(.flexible(), spacing: columnSpacing),
            GridItem(.flexible(), spacing: columnSpacing)
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(viewModel.tasks.indices, id: \.self) { index in
                        ClockTaskView(
                            task: viewModel.tasks[index],
                            viewModel: viewModel,
                            onTaskSolved: checkAllTasksSolved
                        )
                    }
                }
                .padding()
            }
            
            if showCoins {
                FallingCoinsView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationTitle("Ustaw poprawny czas ⏰")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.resetGame()
            showCoins = false
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .animation(.spring(), value: showCoins)
        .alert("Congratulations!".localized + "\n" + elapsedTime.formattedTime, isPresented: $shouldShowNameAlert) {
            TextField("Nickname".localized, text: $userName)
            Button("Save".localized) {
                saveResultAndShowVictory()
            }
            Button("Skip".localized, role: .cancel) {
                //showingVictoryView = true
            }
        } message: {
            Text("Enter your nickname to save the result".localized)
        }
        .onChange(of: showCoins) { completed in
            if completed {
                stopTimer()
                shouldShowNameAlert = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(elapsedTime.formattedTimeWithMilliseconds)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16,
                                  weight: .bold,
                                  design: .monospaced))
                    .foregroundColor(.blue.opacity(viewModel.settings.isTimerOn ? 1 : 0))
            }
        }
    }
    

    
    private func checkAllTasksSolved() {
        if viewModel.allTasksSolved() {
                showCoins = true
            }
    }
    
    private func saveResultAndShowVictory() {
        let difficulty = DifficultyLevel(rawValue: viewModel.settings.difficultyLevel) ?? .medium
        viewModel.settings.saveGameResult(
            name: userName.isEmpty ? "Anonymous" : userName,
            difficulty: difficulty,
            exampleCount: viewModel.settings.exampleCount,
            time: elapsedTime
        )
    }
    
    private func startTimer() {
        guard startTime == nil else { return }
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Single Task View
// MARK: - Single Clock Task View
struct ClockTaskView: View {
    let task: ClockTask
    @ObservedObject var viewModel: ClockGameViewModel
    var onTaskSolved: () -> Void  // Closure to notify parent when solved

    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect = false
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 12) {
            Text(formatted(time: task.date))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            AnalogClockView(
                hourAngle: $hourAngle,
                minuteAngle: $minuteAngle,
                isCorrect: isCorrect,
                isLocked: isCorrect,
                onDragEnded: { check() }
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            
            if isCorrect {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                    Text("Świetnie!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.green)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: isCorrect ? .green.opacity(0.3) : .black.opacity(0.1), radius: 12, y: 6)
    }

    private func check() {
        guard !isCorrect else { return }

        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let targetHourAngle = (Double(components.hour! % 12) * 30) + (Double(components.minute!) / 60 * 30)
        let targetMinuteAngle = Double(components.minute!) * 6

        let tolerance = viewModel.toleranceForDifficulty()

        let wasCorrect = isCorrect
        isCorrect = angularDifference(hourAngle, targetHourAngle) < tolerance.hour &&
                    angularDifference(minuteAngle, targetMinuteAngle) < tolerance.minute

        if isCorrect && !wasCorrect {
            playSuccessSound()
            viewModel.markTaskSolved(task)   // 👈 mark in ViewModel
            onTaskSolved()
        }
    }

    private func angularDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }

    private func formatted(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: task.date)
    }

    private func playSuccessSound() {
        guard let soundURL = Bundle.main.url(forResource: "stars", withExtension: "m4a") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}

// MARK: - Analog Clock
struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool
    var isLocked: Bool
    
    var onDragEnded: (() -> Void)?
    
    @State private var draggingHand: DraggingHand? = nil
    
    enum DraggingHand {
        case hour, minute
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = size / 2

            ZStack {
                // Zewnętrzny gradient ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isCorrect ? [.green, .green.opacity(0.6)] : [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .shadow(color: isCorrect ? .green.opacity(0.3) : .blue.opacity(0.2), radius: 8, y: 4)
                
                // Białe tło
                Circle()
                    .fill(Color.white)
                    .padding(8)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                // Kolorowe znaczniki dla ważnych godzin
                ForEach(1...12, id: \.self) { hour in
                    Circle()
                        .fill(hourColor(for: hour))
                        .frame(width: 8, height: 8)
                        .offset(y: -center + 20)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }
                
                // Cienkie kreski co minutę
                ForEach(0..<60) { tick in
                    if tick % 5 != 0 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 4)
                            .offset(y: -center + 14)
                            .rotationEffect(.degrees(Double(tick) * 6))
                    }
                }

                // Cyfry
                ForEach(1...12, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: size * 0.08, weight: .bold, design: .rounded))
                        .foregroundColor(hourColor(for: number))
                        .position(position(for: Double(number) * 30, size: size))
                }

                // Wskazówka godzinowa - krótka i gruba
                FancyClockHand(
                    length: center * 0.45,
                    width: 10,
                    angle: hourAngle,
                    color: draggingHand == .hour ? .orange : .blue,
                    isDragging: draggingHand == .hour
                )
                
                // Wskazówka minutowa - długa i cienka
                FancyClockHand(
                    length: center * 0.7,
                    width: 6,
                    angle: minuteAngle,
                    color: draggingHand == .minute ? .orange : .red,
                    isDragging: draggingHand == .minute
                )

                // Środkowy punkt
                ZStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 20, height: 20)
                        .shadow(color: .orange.opacity(0.5), radius: 4, y: 2)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Jeśli zegar zablokowany, ignoruj gesty
                        if isLocked {
                            return
                        }
                        
                        let centerPoint = CGPoint(x: size / 2, y: size / 2)
                        
                        if draggingHand == nil {
                            draggingHand = determineClosestHand(
                                touchPoint: value.startLocation,
                                center: centerPoint,
                                hourAngle: hourAngle,
                                minuteAngle: minuteAngle,
                                hourLength: center * 0.45,
                                minuteLength: center * 0.7
                            )
                        }
                        
                        let newAngle = angleFromPoint(value.location, center: centerPoint)
                        
                        if draggingHand == .hour {
                            hourAngle = newAngle
                        } else if draggingHand == .minute {
                            minuteAngle = newAngle
                        }
                    }
                    .onEnded { _ in
                        draggingHand = nil
                        onDragEnded?()
                    }
            )
        }
    }
    
    private func hourColor(for hour: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        return colors[(hour - 1) % colors.count]
    }

    private func position(for angle: Double, size: CGFloat) -> CGPoint {
        let radius = size * 0.38
        let radians = (angle - 90) * .pi / 180

        return CGPoint(
            x: size / 2 + radius * CGFloat(Foundation.cos(radians)),
            y: size / 2 + radius * CGFloat(Foundation.sin(radians))
        )
    }
    
    private func angleFromPoint(_ point: CGPoint, center: CGPoint) -> Double {
        let vector = CGVector(dx: point.x - center.x, dy: point.y - center.y)
        let radians = atan2(vector.dy, vector.dx)
        let degrees = radians * 180 / .pi + 90
        return degrees < 0 ? degrees + 360 : degrees
    }
    
    private func determineClosestHand(
        touchPoint: CGPoint,
        center: CGPoint,
        hourAngle: Double,
        minuteAngle: Double,
        hourLength: CGFloat,
        minuteLength: CGFloat
    ) -> DraggingHand {
        let hourTip = tipPosition(angle: hourAngle, length: hourLength, center: center)
        let distanceToHour = distance(from: touchPoint, to: hourTip)
        
        let minuteTip = tipPosition(angle: minuteAngle, length: minuteLength, center: center)
        let distanceToMinute = distance(from: touchPoint, to: minuteTip)
        
        return distanceToHour < distanceToMinute ? .hour : .minute
    }
    
    private func tipPosition(angle: Double, length: CGFloat, center: CGPoint) -> CGPoint {
        let radians = (angle - 90) * .pi / 180
        return CGPoint(
            x: center.x + length * CGFloat(cos(radians)),
            y: center.y + length * CGFloat(sin(radians))
        )
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Fancy Clock Hand
struct FancyClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let angle: Double
    let color: Color
    let isDragging: Bool

    var body: some View {
        ZStack {
            // Cień wskazówki
            RoundedRectangle(cornerRadius: width / 2)
                .fill(color.opacity(0.3))
                .frame(width: width + 2, height: length)
                .offset(y: -length / 2)
                .blur(radius: 3)
            
            // Główna wskazówka
            RoundedRectangle(cornerRadius: width / 2)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: length)
                .offset(y: -length / 2)
                .shadow(color: color.opacity(0.5), radius: isDragging ? 8 : 4, y: 2)
            
            // Strzałka na końcu
            Triangle()
                .fill(color)
                .frame(width: width * 2, height: width * 2)
                .offset(y: -length + width)
                .shadow(color: color.opacity(0.5), radius: isDragging ? 6 : 3, y: 1)
        }
        .rotationEffect(.degrees(angle))
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}




import SwiftUI
import MediaPlayer

struct FallingCoinsView: View {
    @State private var coins: [Coin] = []
    @State private var timer: Timer?
    @State private var audioPlayer: AVAudioPlayer?

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
            
            ForEach(coins) { coin in
                Image("coin")
                    .resizable()
                    .frame(width: coin.size, height: coin.size)
                    .rotationEffect(.degrees(coin.rotation))
                    .position(x: coin.x, y: coin.y)
                    .onAppear {
                        animateCoinDrop(coin)
                    }
            }
        }
        .onAppear {
            startCoinRain()
//            playCoinSound()
            SoundManager.shared.playSound(named: "coin_sound", loop: true)
        }
        .onDisappear {
            stopCoinRain()
            SoundManager.shared.stopSound()
        }
    }

    func startCoinRain() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            let newCoin = Coin(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: -150,
                size: CGFloat.random(in: 50...200),
                rotation: Double.random(in: 0...200),
                duration: Double.random(in: 0.7...3)
            )
            coins.append(newCoin)
        }
    }

    func animateCoinDrop(_ coin: Coin) {
        if let index = coins.firstIndex(where: { $0.id == coin.id }) {
            withAnimation(.linear(duration: coin.duration)) {
                coins[index].y = screenHeight + 50
            }

            // Usunięcie monety po animacji
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
