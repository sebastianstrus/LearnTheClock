//
//  ContentView.swift
//  Learn the Clock!
//
//  Created by Sebastian Strus on 1/9/26.
//

import SwiftUI
import AVFoundation

// MARK: - Models
struct ClockTask: Identifiable {
    let id = UUID()
    let date: Date
}

// MARK: - App Entry
struct ContentView: View {
    var body: some View {
        NavigationStack {
            StartView()
        }
    }
}

// MARK: - Start View
struct StartView: View {
    @State private var countText: String = "10"
    @State private var tasks: [ClockTask] = []
    @State private var navigate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("🕐")
                        .font(.system(size: 60))
                    
                    Text("Nauka Zegara")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                VStack(spacing: 16) {
                    Text("Ile zegarków chcesz?")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    TextField("10", text: $countText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(width: 120, height: 60)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
                
                Button(action: {
                    generateTasks()
                    navigate = true
                }) {
                    HStack(spacing: 12) {
                        Text("Start")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28))
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 70)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .blue.opacity(0.4), radius: 12, y: 6)
                }

                NavigationLink(
                    destination: ClockGridView(tasks: tasks),
                    isActive: $navigate
                ) { EmptyView() }
            }
            .padding()
        }
    }

    private func generateTasks() {
        let count = min(max(Int(countText) ?? 1, 1), 30)

        tasks = (0..<count).map { _ in
            let hour = Int.random(in: 0...23)
            let minute = Int.random(in: 0...11) * 5

            var components = DateComponents()
            components.hour = hour
            components.minute = minute

            return ClockTask(date: Calendar.current.date(from: components)!)
        }
    }
}

// MARK: - Grid View
struct ClockGridView: View {
    let tasks: [ClockTask]

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
                    ForEach(tasks) { task in
                        ClockTaskView(task: task)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Ustaw poprawny czas ⏰")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Single Task View
struct ClockTaskView: View {
    let task: ClockTask

    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect = false
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 12) {
            Text(formatted(time: task.date))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
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
                isLocked: isCorrect
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
        .onChange(of: hourAngle) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                check()
            }
        }
        .onChange(of: minuteAngle) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                check()
            }
        }
    }

    private func check() {
        // Jeśli już poprawnie ustawione, nie sprawdzaj ponownie
        if isCorrect {
            return
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let targetHour24 = components.hour!
        let targetMinute = components.minute!

        let targetHourAngle = (Double(targetHour24 % 12) * 30)
            + (Double(targetMinute) / 60.0 * 30.0)

        let targetMinuteAngle = Double(targetMinute) * 6

        let hourDiff = angularDifference(hourAngle, targetHourAngle)
        let minuteDiff = angularDifference(minuteAngle, targetMinuteAngle)

        let wasCorrect = isCorrect
        isCorrect = hourDiff < (10.0 / 3.0) && minuteDiff < (5.0 / 3.0)
        
        // Odtwórz dźwięk gdy po raz pierwszy ustawiono poprawnie
        if isCorrect && !wasCorrect {
            playSuccessSound()
        }
    }

    private func angularDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }

    private func formatted(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    private func playSuccessSound() {
        guard let soundURL = Bundle.main.url(forResource: "stars", withExtension: "m4a") else {
            print("Nie znaleziono pliku stars.m4a")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Błąd odtwarzania dźwięku: \(error)")
        }
    }
}

// MARK: - Analog Clock
struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool
    var isLocked: Bool
    
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

#Preview {
    ContentView()
}
