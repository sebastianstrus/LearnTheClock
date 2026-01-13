//
//  Learn_the_Clock_App.swift
//  Learn the Clock!
//
//  Created by Sebastian Strus on 1/9/26.
//

import SwiftUI

@main
struct Learn_the_Clock_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}




import SwiftUI

struct ContentViewClaude: View {
    @State private var targetTime: String = ""
    @State private var targetHour: Int = 0
    @State private var targetMinute: Int = 0
    @State private var hourAngle: Double = 0
    @State private var minuteAngle: Double = 0
    @State private var isCorrect: Bool = false
    @State private var gameStarted: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            if gameStarted {
                Text(targetTime)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            ZStack {
                // Tło zegarka
                Circle()
                    .fill(isCorrect ? Color.green.opacity(0.3) : Color.white)
                    .shadow(radius: 10)
                
                Circle()
                    .stroke(isCorrect ? Color.green : Color.black, lineWidth: 4)
                
                // Znaczniki godzin i minut
                ForEach(0..<60) { tick in
                    TickMark(tick: tick)
                }
                
                // Cyfry godzin
                ForEach(1..<13) { hour in
                    HourNumber(hour: hour)
                }
                
                // Wskazówka minutowa
                MinuteHand(angle: $minuteAngle, isCorrect: isCorrect)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateMinuteAngle(location: value.location)
                            }
                    )
                
                // Wskazówka godzinowa
                HourHand(angle: $hourAngle, isCorrect: isCorrect)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateHourAngle(location: value.location)
                            }
                    )
                
                // Środek zegarka
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
            }
            .frame(width: 300, height: 300)
            
            if !gameStarted {
                Button(action: startGame) {
                    Text("Start")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
            } else {
                Button(action: startGame) {
                    Text("Nowy czas")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.orange)
                        .cornerRadius(15)
                }
            }
        }
        .padding()
    }
    
    func startGame() {
        let randomHour = Int.random(in: 0...23)
        let randomMinute = Int.random(in: 0...11) * 5
        
        targetHour = randomHour
        targetMinute = randomMinute
        targetTime = String(format: "%02d:%02d", randomHour, randomMinute)
        
        hourAngle = 0
        minuteAngle = 0
        isCorrect = false
        gameStarted = true
    }
    
    func updateHourAngle(location: CGPoint) {
        let center = CGPoint(x: 150, y: 150)
        let angle = atan2(location.y - center.y, location.x - center.x)
        hourAngle = angle * 180 / .pi + 90
        checkAnswer()
    }
    
    func updateMinuteAngle(location: CGPoint) {
        let center = CGPoint(x: 150, y: 150)
        let angle = atan2(location.y - center.y, location.x - center.x)
        minuteAngle = angle * 180 / .pi + 90
        checkAnswer()
    }
    
    func checkAnswer() {
        let normalizedHourAngle = (hourAngle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let normalizedMinuteAngle = (minuteAngle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        
        // Konwersja czasu 24h na pozycję 12h
        let displayHour = targetHour % 12
        let expectedHourAngle = Double(displayHour) * 30 + Double(targetMinute) * 0.5
        let expectedMinuteAngle = Double(targetMinute) * 6
        
        let hourDiff = min(abs(normalizedHourAngle - expectedHourAngle),
                          360 - abs(normalizedHourAngle - expectedHourAngle))
        let minuteDiff = min(abs(normalizedMinuteAngle - expectedMinuteAngle),
                            360 - abs(normalizedMinuteAngle - expectedMinuteAngle))
        
        isCorrect = hourDiff < 10 && minuteDiff < 10
    }
}

struct TickMark: View {
    let tick: Int
    
    var body: some View {
        let isHourMark = tick % 5 == 0
        let angle = Double(tick) * 6
        
        Rectangle()
            .fill(Color.black)
            .frame(width: isHourMark ? 3 : 1.5, height: isHourMark ? 15 : 8)
            .offset(y: -135)
            .rotationEffect(.degrees(angle))
    }
}

struct HourNumber: View {
    let hour: Int
    
    var body: some View {
        let angle = Double(hour) * 30
        let radius: CGFloat = 105
        let x = radius * sin(angle * .pi / 180)
        let y = -radius * cos(angle * .pi / 180)
        
        Text("\(hour)")
            .font(.system(size: 24, weight: .bold))
            .offset(x: x, y: y)
    }
}

struct HourHand: View {
    @Binding var angle: Double
    let isCorrect: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isCorrect ? Color.green : Color.black)
            .frame(width: 8, height: 70)
            .offset(y: -35)
            .rotationEffect(.degrees(angle))
    }
}

struct MinuteHand: View {
    @Binding var angle: Double
    let isCorrect: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(isCorrect ? Color.green : Color.blue)
            .frame(width: 6, height: 100)
            .offset(y: -50)
            .rotationEffect(.degrees(angle))
    }
}







import SwiftUI

struct ContentViewGemini: View {
    @State private var targetTime: (hour: Int, minute: Int) = (0, 0)
    @State private var hourAngle: Angle = .degrees(0)
    @State private var minuteAngle: Angle = .degrees(0)
    @State private var isCorrect: Bool = false
    @State private var gameStarted: Bool = false

    var body: some View {
        VStack(spacing: 40) {
            if gameStarted {
                Text(String(format: "%02d:%02d", targetTime.hour, targetTime.minute))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Text("Naciśnij Start")
                    .font(.largeTitle)
            }

            // Tarcza zegara
            ZStack {
                Circle()
                    .strokeBorder(isCorrect ? Color.green : Color.black, lineWidth: 8)
                    .background(Circle().fill(isCorrect ? Color.green.opacity(0.1) : Color.clear))
                    .frame(width: 300, height: 300)

                // Znaczniki 5-minutowe (kreski)
                ForEach(0..<60) { tick in
                    Rectangle()
                        .fill(tick % 5 == 0 ? Color.black : Color.gray.opacity(0.5))
                        .frame(width: tick % 5 == 0 ? 3 : 1, height: tick % 5 == 0 ? 15 : 7)
                        .offset(y: -140)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }

                // Numery godzin
                ForEach(1...12, id: \.self) { num in
                    Text("\(num)")
                        .font(.system(size: 24, weight: .bold))
                        .position(
                            x: 150 + 110 * cos(CGFloat(num * 30 - 90) * .pi / 180),
                            y: 150 + 110 * sin(CGFloat(num * 30 - 90) * .pi / 180)
                        )
                }

                // Wskazówka godzinowa
                Hand(color: .black, width: 8, height: 70, angle: hourAngle)
                    .gesture(DragGesture().onChanged { value in updateAngle(value, forHour: true) })

                // Wskazówka minutowa
                Hand(color: .blue, width: 4, height: 110, angle: minuteAngle)
                    .gesture(DragGesture().onChanged { value in updateAngle(value, forHour: false) })

                // Środek zegara
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
            }
            .frame(width: 300, height: 300)

            Button(action: startGame) {
                Text(gameStarted ? "Losuj ponownie" : "Start")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // Logika losowania czasu
    func startGame() {
        let h = Int.random(in: 0...23)
        let m = Int.random(in: 0...11) * 5 // Minuty podzielne przez 5
        targetTime = (h, m)
        isCorrect = false
        gameStarted = true
    }

    // Logika przeciągania wskazówek
    func updateAngle(_ value: DragGesture.Value, forHour: Bool) {
        let vector = CGVector(dx: value.location.x - 150, dy: value.location.y - 150)
        let radians = atan2(vector.dy, vector.dx)
        var degrees = Double(radians * 180 / .pi) + 90
        if degrees < 0 { degrees += 360 }

        if forHour {
            // Skok co 30 stopni (godzina)
            let snapped = (degrees / 30).rounded() * 30
            hourAngle = .degrees(snapped)
        } else {
            // Skok co 6 stopni (minuta)
            let snapped = (degrees / 6).rounded() * 6
            minuteAngle = .degrees(snapped)
        }
        checkAnswer()
    }

    // Sprawdzenie poprawności
    func checkAnswer() {
        let currentHour = Int(hourAngle.degrees.rounded()) / 30
        let currentMin = Int(minuteAngle.degrees.rounded()) / 6
        
        let targetH12 = targetTime.hour % 12
        let normalizedHour = currentHour == 0 ? 0 : (currentHour == 12 ? 0 : currentHour)
        let targetHourNormalized = targetH12 == 12 ? 0 : targetH12

        if normalizedHour == targetHourNormalized && currentMin == targetTime.minute {
            isCorrect = true
        } else {
            isCorrect = false
        }
    }
}

// Komponent wskazówki
struct Hand: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let angle: Angle

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: width, height: height)
            .offset(y: -height / 2)
            .rotationEffect(angle)
    }
}







