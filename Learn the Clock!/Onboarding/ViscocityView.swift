//
//  ViscocityView.swift
//  RippleGeography_UI
//
//  Created by Sebastian Strus on 22/08/25.
//

import SwiftUI

struct ViscosityView: View {
    
    @State private var scale1: CGFloat = 1
    @State private var scale2: CGFloat = 1
    @State private var isFillMode: Bool = true
    
    var scale: CGFloat = 1
    
    var colorOne: Color = .red
    var colorTwo: Color = .black
    
    var limit: Int = 70
    
    var body: some View {
        ZStack {
            viscosityView(color: colorOne, scale: $scale1)
            viscosityView(color: colorTwo, scale: $scale2)
            
        }
        .edgesIgnoringSafeArea(.all)
        .scaleEffect(scale)
    }
    
    private func viscosityView(color: Color, scale: Binding<CGFloat>) -> some View {
        GeometryReader { geo in
            ViscosityCanvas(color: color, limit: limit) {
                circle(canvasSize: geo.size, scale: scale, limit: limit)
            }
        }
    }
    
    @ViewBuilder
    private func circle(canvasSize: CGSize, scale: Binding<CGFloat>, limit: Int) -> some View {
        let min = min(canvasSize.width, canvasSize.height) * 0.09
        let width: CGFloat = .random(in: min...(min * 2.6))
        let height: CGFloat = .random(in: min...(min * 2.6))
        
        ForEach(0..<limit, id: \.self) { index in
            Circle()
                .frame(width: width, height: height)
                .scaleEffect(scale.wrappedValue * .random(in: 0.1..<1.5))
                .animation(Animation.easeInOut(duration: 3)
                    .repeatForever()
                    .speed(.random(in: 0.2...1.0)), value: scale.wrappedValue)
                .position(CGPoint(x: .random(in: 0..<canvasSize.width),
                                  y: .random(in: 0..<canvasSize.height)))
                .tag(index)
        }
        .onAppear {
            scale.wrappedValue = scale.wrappedValue == 1.2 ? 1.0 : 1.2
        }
    }
}

fileprivate
struct ViscosityCanvas<Symbols: View> : View {
    
    let color: Color
    let thresholdMin: CGFloat
    let thresholdMax: CGFloat?
    let radius: CGFloat
    let symbols: () -> Symbols
    
    var limit: Int
    
    var body: some View {
        Canvas { context, size in
            if let thresholdMax = thresholdMax {
                context.addFilter(.alphaThreshold(min: thresholdMin, max: thresholdMax, color: color))
            } else {
                context.addFilter(.alphaThreshold(min: thresholdMin, color: color))
            }
            context.addFilter(.blur(radius: 14))
            context.drawLayer { ctx in
                for index in 0 ..< limit - 10 {
                    if let view = context.resolveSymbol(id: index) {
                        ctx.draw(view, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                }
            }
        } symbols: {
            symbols()
        }
    }
    
    init(color: Color, thresholdMin: CGFloat = 0.5, thresholdMax: CGFloat? = nil, radius: CGFloat = 12, limit: Int, @ViewBuilder symbols: @escaping () -> Symbols) {
        self.color = color
        self.thresholdMin = thresholdMin
        self.thresholdMax = thresholdMax
        self.radius = radius
        self.symbols = symbols
        
        self.limit = limit
    }
}

struct ViscosityView_Previews: PreviewProvider {
    static var previews: some View {
        ViscosityView(limit: 20)
    }
}

