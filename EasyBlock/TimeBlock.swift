import SwiftUI

/// A visual block representing a scheduled time range.
///
/// Provide the vertical start and end positions (in points) and the available width.
/// The block will render from the lesser of start/end to the greater, with a minimum height of 1.
struct TimeBlock: View {
    let title: String
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
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.accentColor.opacity(0.25))
                .overlay(
                    Rectangle().stroke(Color.accentColor, lineWidth: 1)
                )
            // Title label inside the block
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
                .padding(6)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: width, height: rectHeight)
        .offset(x: 0, y: rectY)
        .accessibilityLabel("Time block")
        .accessibilityValue("")
        .accessibilityHint("\(title). From \(Int(rectY)) to \(Int(rectY + rectHeight)) points")
    }
}

#Preview {
    ZStack(alignment: .topLeading) {
        Color.clear
        TimeBlock(title: "Morning Focus", yStart: 50, yEnd: 150, width: 200)
    }
    .frame(width: 220, height: 220)
    .padding()
}
