import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    @State private var pressLocation: CGPoint? = nil
    @State private var blocks: [(title: String, range: ClosedRange<Int>)] = []
    @State private var contentHeight: CGFloat = 0
    @State private var selectedBlock: (title: String, range: ClosedRange<Int>)? = nil
    private var maxY: Int { Int(max(0, contentHeight.rounded(.down))) }
    
    private struct IdentifiedBlock: Identifiable {
        let id: UUID
        let title: String
        let range: ClosedRange<Int>
    }
    
    func setShowModal(drag: DragGesture.Value?) {
        let location = drag?.location ?? .zero
        pressLocation = location   // This triggers the sheet!
    }
    
    // Long press followed by a no-move drag to capture location
    private var longPressThenDrag: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { value in
                switch value {
                case .second(true, let drag?):
                    setShowModal(drag: drag)
                default:
                    break
                }
            }
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
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
                .background(
                    GeometryReader { inner in
                        Color.clear
                            .onAppear { contentHeight = inner.size.height }
                            .onChange(of: inner.size.height) { _, newValue in
                                contentHeight = newValue
                            }
                    }
                )
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        ForEach(Array(blocks.enumerated()), id: \.offset) { _, item in
                            let range = item.range
                            let title = item.title
                            let yStart = CGFloat(range.lowerBound)
                            let yEndExclusive = CGFloat(range.upperBound)
                            TimeBlock(title: title, yStart: yStart, yEnd: yEndExclusive, width: width) {
                                selectedBlock = (title: title, range: range)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(longPressThenDrag) // attach here so coordinates are relative to this VStack
            }
        }
        .sheet(isPresented: Binding(get: { pressLocation != nil }, set: { if !$0 { pressLocation = nil } })) {
            let location = pressLocation ?? .zero
            AddTimeBlockModal(
                pressLocation: location,
                isPresented: Binding(get: { pressLocation != nil }, set: { if !$0 { pressLocation = nil } }),
                maxY: maxY,
                onSave: { title, start, end in
                    blocks.append((title: title, range: start...(end - 1)))
                }
            )
            .padding()
            .presentationDetents([.medium, .large])
        }
        .sheet(item: Binding(get: {
            selectedBlock.map { IdentifiedBlock(id: UUID(), title: $0.title, range: $0.range) }
        }, set: { newValue in
            if let newValue = newValue {
                selectedBlock = (title: newValue.title, range: newValue.range)
            } else {
                selectedBlock = nil
            }
        })) { identified in
            TimeBlockDetailView(title: identified.title, range: identified.range)
                .presentationDetents([.medium, .large])
        }
    }
}

private struct TimeBlockDetailView: View {
    let title: String
    let range: ClosedRange<Int>

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                HStack {
                    Text("Start:")
                    Text("\(range.lowerBound)")
                        .monospaced()
                }
                HStack {
                    Text("End:")
                    Text("\(range.upperBound)")
                        .monospaced()
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Time Block")
        }
    }
}
