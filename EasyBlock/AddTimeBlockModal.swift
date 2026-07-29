VStack(spacing: 16) {
                Text("Long Press Detected")
                    .font(.title2)
                Text("x: \(Int(pressLocation.x)), y: \(Int(pressLocation.y))")
                    .monospaced()
                Button("Dismiss") {
                    showModal = false
                }
            }