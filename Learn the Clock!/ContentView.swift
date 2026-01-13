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

        let targetHourAngle = (Double(targetHour24 % 12) * 30)
            + (Double(targetMinute) / 60.0 * 30.0)

        let targetMinuteAngle = Double(targetMinute) * 6

        let hourDiff = angularDifference(hourAngle, targetHourAngle)
        let minuteDiff = angularDifference(minuteAngle, targetMinuteAngle)

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
struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool

    @State private var draggingHand: DraggingHand? = nil

    enum DraggingHand {
        case hour, minute
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let size = min(width, height)
            let center = size / 2

            ZStack {
                // Face
                Circle()
                    .stroke(isCorrect ? Color.green : Color.primary, lineWidth: 5)

                // Ticks
                TicksView(center: center)

                // Numbers
                NumbersView(size: size)

                // Hour hand
                ClockHand(
                    length: center * 0.45,
                    width: 5,
                    angle: hourAngle,
                    color: draggingHand == .hour ? .blue : .primary
                )

                // Minute hand
                ClockHand(
                    length: center * 0.7,
                    width: 3,
                    angle: minuteAngle,
                    color: draggingHand == .minute ? .red : .primary
                )

                // Pin
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
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

                        switch draggingHand {
                        case .hour:
                            hourAngle = newAngle
                        case .minute:
                            minuteAngle = newAngle
                        case .none:
                            break
                        }
                    }
                    .onEnded { _ in
                        draggingHand = nil
                    }
            )
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

// Extracted subviews to reduce type-checking complexity
private struct TicksView: View {
    let center: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<60) { tick in
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: tick % 5 == 0 ? 3 : 1,
                           height: tick % 5 == 0 ? 10 : 5)
                    .offset(y: -center + 8)
                    .rotationEffect(.degrees(Double(tick) * 6))
            }
        }
    }
}

private struct NumbersView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(1...12, id: \.self) { number in
                Text("\(number)")
                    .font(.caption)
                    .position(position(for: Double(number) * 30, size: size))
            }
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

// MARK: - Clock Hand (prosty view bez gestów)
struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let angle: Double
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
    }
}

#Preview {
    ContentView()
}
