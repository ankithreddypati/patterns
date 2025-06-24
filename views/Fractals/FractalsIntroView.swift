

import SwiftUI

struct FractalsIntroView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Fractals")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 10)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("""
                        **Observation**: Some shapes in nature repeat themselves at different scales whether you zoom in or out, you'll see the same patterns. These are called fractals. we see this everywhere from tree branches , lightining , moutains , coastline
                        """)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                       // .fontWeight(.semibold)
                    }
                }
                .frame(height: 220)
                .background(.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 15)
                
                HStack(spacing: 80) {
                    FractalView(type: .kochSnowflake)
                   // FractalView(type: .lightning)
                    FractalView(type: .spiralGalaxy)
                }
                .padding(.horizontal, 20)
                
                ScrollView {
                    VStack {
                        Text("""
                        **Application** : Humans have found smarter ways to design and understand the world 
                        Engineers used fractals to design better antennas that capture signals from multiple directions in a smaller space.
                        """)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                       .padding(.vertical )
                       // .fontWeight(.semibold)
                    }
                }
                .frame(height: 210)
                .background(.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 15)
                
                Spacer(minLength: 20)
                
                HStack {
            

                    
                    NavigationLink(destination: TreeFractalView()) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .onAppear {
            overlaySettings.isHandPoseEnabled = false
        }
    }
}

enum FractalType {
    case kochSnowflake, spiralGalaxy
}

struct FractalView: View {
    let type: FractalType
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var time = Date()
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            TimelineView(.animation(minimumInterval: 0.1, paused: false)) { timeline in
                Canvas { context, size in
                    let timeInterval = timeline.date.timeIntervalSince(time)
                    
                    switch type {
                    case .kochSnowflake:
                        drawKochSnowflake(in: &context, size: size, time: timeInterval)
                    case .spiralGalaxy:
                        drawSpiralGalaxy(in: &context, size: size, time: timeInterval)
                    default:
                        break
                    }
                }
                .frame(width: horizontalSizeClass == .regular && verticalSizeClass == .regular ? 190 : 120,
                       height: horizontalSizeClass == .regular && verticalSizeClass == .regular ? 350 : 120)
                .background(Color.white)
                .cornerRadius(10)
            }

            Text(type == .kochSnowflake ? "Koch Snowflake" : "Spiral Galaxy")
                .font(.caption)
                .foregroundColor(.black)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

func drawKochSnowflake(in context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let radius = min(size.width, size.height) * 0.4
    let sides = 3
    let angle = 2 * Double.pi / Double(sides)
    
    var points: [CGPoint] = []
    for i in 0..<sides {
        let x = center.x + radius * cos(angle * Double(i) - Double.pi / 2)
        let y = center.y + radius * sin(angle * Double(i) - Double.pi / 2)
        points.append(CGPoint(x: x, y: y))
    }
    
    let depth = Int(time) % 5 + 1
    
    for i in 0..<sides {
        let start = points[i]
        let end = points[(i + 1) % sides]
        drawKochLine(in: &context, start: start, end: end, depth: depth)
    }
}

func drawKochLine(in context: inout GraphicsContext, start: CGPoint, end: CGPoint, depth: Int) {
    guard depth > 0 else {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(.blue), lineWidth: 2)
        return
    }
    
    let vector = CGPoint(x: end.x - start.x, y: end.y - start.y)
    let length = sqrt(vector.x * vector.x + vector.y * vector.y)
    let unit = CGPoint(x: vector.x / length, y: vector.y / length)
    
    let third = length / 3
    let p1 = CGPoint(x: start.x + unit.x * third, y: start.y + unit.y * third)
    let p3 = CGPoint(x: end.x - unit.x * third, y: end.y - unit.y * third)
    
    let angle = -Double.pi / 3
    let p2 = CGPoint(
        x: p1.x + third * (cos(angle) * unit.x - sin(angle) * unit.y),
        y: p1.y + third * (sin(angle) * unit.x + cos(angle) * unit.y)
    )
    
    drawKochLine(in: &context, start: start, end: p1, depth: depth - 1)
    drawKochLine(in: &context, start: p1, end: p2, depth: depth - 1)
    drawKochLine(in: &context, start: p2, end: p3, depth: depth - 1)
    drawKochLine(in: &context, start: p3, end: end, depth: depth - 1)
}



func drawSpiralGalaxy(in context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let maxRadius = min(size.width, size.height) * 0.4
    let rotationSpeed = time * 2
    
    for i in 0..<300 {
        let progress = Double(i) / 300
        let angle = progress * 15 * Double.pi + rotationSpeed
        let radius = progress * maxRadius
        
        let x = center.x + CGFloat(cos(angle) * radius)
        let y = center.y + CGFloat(sin(angle) * radius)
        
        let pulsingOpacity = 0.3 + 0.7 * abs(sin(time + progress * 4))
        let color = Color.purple.opacity(pulsingOpacity)
        
        var path = Path()
        let dotSize = (1 - progress) * 3
        path.addEllipse(in: CGRect(x: x - CGFloat(dotSize/2), y: y - CGFloat(dotSize/2),
                                 width: CGFloat(dotSize), height: CGFloat(dotSize)))
        context.fill(path, with: .color(color))
    }
}

#Preview {
    FractalsIntroView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
