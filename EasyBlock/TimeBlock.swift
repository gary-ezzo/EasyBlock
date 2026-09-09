import SwiftUI

/// A visual block representing a scheduled time range.
///
/// Provide the vertical start and end positions (in points) and the available width.
/// The block will render from the lesser of start/end to the greater, with a minimum height of 1.
struct TimeBlock: View {
    let yStart: CGFloat
    let yEnd: CGFloat
    let width: CGFloat

    private var rectY: CGFloat {
        min(yStart, yEnd)
    }

    private var rectHeight: CGFloat {
        max(1, abs(yEnd - yStart))
    }

    var body: some View {
        Rectangle()
            .fill(Color.accentColor.opacity(0.25))
            .overlay(
                Rectangle().stroke(Color.accentColor, lineWidth: 1)
            )
            .frame(width: width, height: rectHeight)
            .offset(x: 0, y: rectY)
            .accessibilityLabel("Time block")
            .accessibilityValue("From \(Int(rectY)) to \(Int(rectY + rectHeight)) points")
    }
}

#Preview {
    ZStack(alignment: .topLeading) {
        Color.clear
        TimeBlock(yStart: 50, yEnd: 150, width: 200)
    }
    .frame(width: 220, height: 220)
    .padding()
}
