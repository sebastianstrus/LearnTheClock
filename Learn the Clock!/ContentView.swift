//
//  ContentView.swift
//  Learn the Clock!
//
//  Created by Sebastian Strus on 1/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var targetTime: Date? = nil
    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if let targetTime {
                Text(formatted(time: targetTime))
                    .font(.largeTitle)
                    .bold()
            } else {
                Text("Kliknij Start")
                    .font(.title)
            }

            AnalogClockView(
                hourAngle: $hourAngle,
                minuteAngle: $minuteAngle,
                isCorrect: isCorrect
            )
            .frame(width: 300, height: 300)

            Button("Start") {
                startGame()
            }
            .font(.title2)
        }
        .padding()
        .onChange(of: hourAngle) { _ in checkAnswer() }
        .onChange(of: minuteAngle) { _ in checkAnswer() }
    }

    private func startGame() {
        let hour = Int.random(in: 0...23)
        let minute = Int.random(in: 0...11) * 5

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        targetTime = Calendar.current.date(from: components)

        hourAngle = 0
        minuteAngle = 0
        isCorrect = false
    }

    private func formatted(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }

    private func checkAnswer() {
        guard let targetTime else { return }

        let components = Calendar.current.dateComponents([.hour, .minute], from: targetTime)
        let targetHour = components.hour! % 12
        let targetMinute = components.minute!

        let hourFromAngle = Int((hourAngle / 30).rounded()) % 12
        let minuteFromAngle = Int((minuteAngle / 6).rounded()) % 60

        isCorrect = hourFromAngle == targetHour && minuteFromAngle == targetMinute
    }
}

struct AnalogClockView: View {
    @Binding var hourAngle: Double
    @Binding var minuteAngle: Double
    var isCorrect: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isCorrect ? Color.green : Color.black, lineWidth: 6)

            ForEach(1...12, id: \.self) { number in
                Text("\(number)")
                    .font(.headline)
                    .position(position(for: Double(number) * 30))
            }

            ForEach(0..<60) { tick in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: tick % 5 == 0 ? 3 : 1, height: tick % 5 == 0 ? 12 : 6)
                    .offset(y: -140)
                    .rotationEffect(.degrees(Double(tick) * 6))
            }

            ClockHand(length: 70, width: 6, angle: $hourAngle)
            ClockHand(length: 110, width: 4, angle: $minuteAngle)

            Circle()
                .fill(Color.black)
                .frame(width: 10, height: 10)
        }
    }

    private func position(for angle: Double) -> CGPoint {
        let radius: CGFloat = 120
        let radians = (angle - 90) * .pi / 180
        return CGPoint(
            x: 150 + radius * Foundation.cos(radians),
            y: 150 + radius * Foundation.sin(radians)
        )
    }
}

struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    @Binding var angle: Double

    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        angle = angleFromDrag(value.location)
                    }
            )
    }

    private func angleFromDrag(_ location: CGPoint) -> Double {
        let center = CGPoint(x: 150, y: 150)
        let vector = CGVector(dx: location.x - center.x, dy: location.y - center.y)
        let radians = atan2(vector.dy, vector.dx)
        let degrees = radians * 180 / .pi + 90
        return degrees < 0 ? degrees + 360 : degrees
    }
}

#Preview {
    ContentView()
}


#Preview {
    ContentView()
}
