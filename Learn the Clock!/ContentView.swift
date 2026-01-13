//
//  ContentView.swift
//  Learn the Clock!
//
//  Created by Sebastian Strus on 1/9/26.
//

import SwiftUI

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
        VStack(spacing: 24) {
            Text("Nauka zegara")
                .font(.largeTitle)
                .bold()

            TextField("Liczba przykładów (np. 10)", text: $countText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)

            Button("Start") {
                generateTasks()
                navigate = true
            }
            .font(.title2)
            .buttonStyle(.borderedProminent)

            NavigationLink(
                destination: ClockGridView(tasks: tasks),
                isActive: $navigate
            ) { EmptyView() }
        }
        .padding()
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
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(tasks) { task in
                    ClockTaskView(task: task)
                }
            }
            .padding()
        }
        .navigationTitle("Ustaw poprawny czas")
    }
}

// MARK: - Single Task View
struct ClockTaskView: View {
    let task: ClockTask

    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect = false

    var body: some View {
        VStack(spacing: 8) {
            Text(formatted(time: task.date))
                .font(.headline)

            AnalogClockView(
                hourAngle: $hourAngle,
                minuteAngle: $minuteAngle,
                isCorrect: isCorrect
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
        }
        .onChange(of: hourAngle) { _ in check() }
        .onChange(of: minuteAngle) { _ in check() }
    }

    private func check() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
        let targetHour24 = components.hour!
        let targetMinute = components.minute!

        // REAL hour angle includes minutes (e.g. 3:55 is almost 4)
        let targetHourAngle = (Double(targetHour24 % 12) * 30)
            + (Double(targetMinute) / 60.0 * 30.0)

        let targetMinuteAngle = Double(targetMinute) * 6

        let hourDiff = angularDifference(hourAngle, targetHourAngle)
        let minuteDiff = angularDifference(minuteAngle, targetMinuteAngle)

        // tolerances in degrees (kid‑friendly)
        // stricter tolerances in degrees (3x smaller)
        isCorrect = hourDiff < (10.0 / 3.0) && minuteDiff < (5.0 / 3.0)
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
}

// MARK: - Analog Clock
// MARK: - Analog Clock (z poprawnym przekazaniem środka)
struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = size / 2

            ZStack {
                Circle()
                    .stroke(isCorrect ? Color.green : Color.primary, lineWidth: 5)

                // Ticks
                ForEach(0..<60) { tick in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: tick % 5 == 0 ? 3 : 1,
                               height: tick % 5 == 0 ? 10 : 5)
                        .offset(y: -center + 8)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }

                // Numbers
                ForEach(1...12, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption)
                        .position(position(for: Double(number) * 30, size: size))
                }

                ClockHand(
                    length: center * 0.45,
                    width: 5,
                    angle: $hourAngle,
                    centerPoint: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                )
                ClockHand(
                    length: center * 0.7,
                    width: 3,
                    angle: $minuteAngle,
                    centerPoint: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                )

                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private func position(for angle: Double, size: CGFloat) -> CGPoint {
        let radius = size * 0.42
        let radians = (angle - 90) * .pi / 180

        return CGPoint(
            x: size / 2 + radius * CGFloat(Foundation.cos(radians)),
            y: size / 2 + radius * CGFloat(Foundation.sin(radians))
        )
    }
}

// MARK: - Clock Hand (z poprawnym środkiem)
struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    @Binding var angle: Double
    let centerPoint: CGPoint

    @State private var lastDragAngle: Double?
    @State private var accumulatedAngle: Double = 0

    var body: some View {
        Rectangle()
            .fill(Color.primary)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let currentDragAngle = angleFromDrag(value.location)
                        
                        if lastDragAngle == nil {
                            // Pierwszy dotyk - ustaw wskazówkę na pozycję palca
                            accumulatedAngle = currentDragAngle
                            angle = currentDragAngle
                            lastDragAngle = currentDragAngle
                        } else {
                            // Oblicz jak bardzo palec się obrócił
                            let delta = shortestAngularDistance(from: lastDragAngle!, to: currentDragAngle)
                            // Obróć wskazówkę o tyle samo
                            accumulatedAngle += delta
                            angle = normalize(accumulatedAngle)
                            lastDragAngle = currentDragAngle
                        }
                    }
                    .onEnded { _ in
                        lastDragAngle = nil
                    }
            )
    }

    private func angleFromDrag(_ location: CGPoint) -> Double {
        // Użyj RZECZYWISTEGO środka zegara, nie GeometryReader!
        let vector = CGVector(dx: location.x - centerPoint.x, dy: location.y - centerPoint.y)
        let radians = atan2(vector.dy, vector.dx)
        let degrees = radians * 180 / .pi + 90
        return degrees < 0 ? degrees + 360 : degrees
    }

    private func normalize(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }
    
    private func shortestAngularDistance(from: Double, to: Double) -> Double {
        var delta = to - from
        
        while delta > 180 {
            delta -= 360
        }
        while delta < -180 {
            delta += 360
        }
        
        return delta
    }
}


#Preview {
    ContentView()
}
