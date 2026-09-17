import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    @State private var pressLocation: CGPoint? = nil
    @State private var blocks: [Block] = []
    @State private var contentHeight: CGFloat = 0
    @State private var selectedBlockID: UUID? = nil
    
    private var maxY: Int { Int(max(0, contentHeight.rounded(.down))) }
    
    struct Block: Identifiable, Equatable {
        let id: UUID
        var title: String
        var range: ClosedRange<Int>
    }
    
    private func indexForBlock(id: UUID) -> Int? {
        blocks.firstIndex(where: { $0.id == id })
    }
    
    private enum ActiveModal: Identifiable {
        case add(CGPoint), edit(Block)
        var id: String { switch self { case .add: return "add"; case .edit(let b): return b.id.uuidString } }
    }
    @State private var activeModal: ActiveModal? = nil
    
    func setShowModal(drag: DragGesture.Value?) {
        let location = drag?.location ?? .zero
        pressLocation = location
        activeModal = .add(location)
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
                        ForEach(blocks) { block in
                            let range = block.range
                            let title = block.title
                            let yStart = CGFloat(range.lowerBound)
                            let yEndExclusive = CGFloat(range.upperBound)
                            TimeBlock(title: title, yStart: yStart, yEnd: yEndExclusive, width: width) {
                                selectedBlockID = block.id
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(longPressThenDrag) // attach here so coordinates are relative to this VStack
                .onChange(of: selectedBlockID) { _, newValue in
                    if let id = newValue, let idx = indexForBlock(id: id) {
                        activeModal = .edit(blocks[idx])
                    }
                }
            }
        }
        .sheet(item: $activeModal) { modal in
            switch modal {
            case .add(let location):
                AddTimeBlockModal(
                    pressLocation: location,
                    isPresented: Binding(get: { activeModal != nil }, set: { if !$0 { activeModal = nil } }),
                    maxY: maxY,
                    existing: nil,
                    onSave: { _, title, start, end in
                        blocks.append(Block(id: UUID(), title: title, range: start...(end - 1)))
                    }
                )
                .padding()
                .presentationDetents([.medium, .large])
            case .edit(let block):
                AddTimeBlockModal(
                    pressLocation: .zero,
                    isPresented: Binding(get: { activeModal != nil }, set: { if !$0 { activeModal = nil } }),
                    maxY: maxY,
                    existing: (id: block.id, title: block.title, start: block.range.lowerBound, end: block.range.upperBound + 1),
                    onSave: { id, title, start, end in
                        if let id, let idx = indexForBlock(id: id) {
                            blocks[idx].title = title
                            blocks[idx].range = start...(end - 1)
                        }
                    }
                )
                .padding()
                .presentationDetents([.medium, .large])
            }
        }
    }
}
