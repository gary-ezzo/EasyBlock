import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    @State private var pressLocation: CGPoint = .zero

    // Long press followed by a no-move drag to capture location
    private var longPressThenDrag: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { value in
                switch value {
                case .second(true, let drag?):
                    // Location in the local coordinate space of the view you attach the gesture to
                    pressLocation = drag.location
                    showModal = true
                default:
                    break
                }
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                ForEach(0..<24, id: \.self) { hour in
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        Text("\(hour, specifier: "%02d")")
                            .font(.headline)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.separator)
                    }
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .gesture(longPressThenDrag) // attach here so coordinates are relative to this VStack
        }
        .sheet(isPresented: $showModal) {
            VStack(spacing: 16) {
                Text("Long Press Detected")
                    .font(.title2)
                Text("x: \(Int(pressLocation.x)), y: \(Int(pressLocation.y))")
                    .monospaced()
                Button("Dismiss") {
                    showModal = false
                }
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}
