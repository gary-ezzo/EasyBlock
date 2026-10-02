import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    @State private var pressLocation: CGPoint? = nil
    @State private var blocks: [(title: String, range: ClosedRange<Int>)] = []
    @State private var contentHeight: CGFloat = 0
    @State private var selectedBlock: (title: String, range: ClosedRange<Int>)? = nil
    @State private var draggingIndex: Int? = nil
    @State private var dragStartOffset: Int = 0
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
                        ForEach(Array(blocks.enumerated()), id: \.offset) { index, item in
                            let baseStart = item.range.lowerBound
                            let baseEndExclusive = item.range.upperBound
                            let isDragging = draggingIndex == index
                            let visualStart: Int = isDragging ? max(0, min(maxY - 1, baseStart + dragStartOffset)) : baseStart
                            let visualEndExclusive: Int = isDragging ? max(visualStart + 1, min(maxY, baseEndExclusive + dragStartOffset)) : baseEndExclusive
                            let yStart = CGFloat(visualStart)
                            let yEndExclusive = CGFloat(visualEndExclusive)
                            let title = item.title
                            let range = item.range
                            TimeBlock(title: title, yStart: yStart, yEnd: yEndExclusive, width: width) {
                                selectedBlock = (title: title, range: range)
                            }
                            .opacity(draggingIndex == index ? 0.9 : 1.0)
                            .gesture(
                                LongPressGesture(minimumDuration: 0.25)
                                    .sequenced(before: DragGesture(minimumDistance: 0))
                                    .onChanged { value in
                                        switch value {
                                        case .first(true):
                                            // long press recognized, set initial drag state
                                            if draggingIndex == nil {
                                                draggingIndex = index
                                                dragStartOffset = 0
                                            }
                                        case .second(true, let drag?):
                                            // update offset based on drag translation in points -> integer rows
                                            let dy = Int(drag.translation.height.rounded(.toNearestOrAwayFromZero))
                                            dragStartOffset = dy
                                        default:
                                            break
                                        }
                                    }
                                    .onEnded { value in
                                        defer { draggingIndex = nil; dragStartOffset = 0 }
                                        guard draggingIndex == index else { return }
                                        var start = baseStart + dragStartOffset
                                        var endExclusive = baseEndExclusive + dragStartOffset
                                        // Clamp to bounds
                                        if start < 0 {
                                            endExclusive -= start // shift down to keep size
                                            start = 0
                                        }
                                        if endExclusive > maxY {
                                            let overflow = endExclusive - maxY
                                            start -= overflow
                                            endExclusive = maxY
                                        }
                                        start = max(0, min(start, maxY - 1))
                                        endExclusive = max(start + 1, min(endExclusive, maxY))
                                        // Commit the move
                                        blocks[index].range = start...(endExclusive - 1)
                                    }
                            )
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(longPressThenDrag) // attach here so coordinates are relative to this VStack
            }
        }
        .sheet(isPresented: Binding(get: { pressLocation != nil }, set: { if !$0 { pressLocation = nil } })) {
            let location = pressLocation ?? .zero
            // Map the press location's y-coordinate into an initial [start, end) range.
            let rawY = Int(location.y.rounded(.down))
            let clampedStart = max(0, min(max(0, maxY - 1), rawY))
            let initialStart = clampedStart
            let initialEnd = min(maxY, clampedStart + 1)

            TimeBlockEditor(
                title: "",
                start: initialStart,
                end: initialEnd,
                maxY: maxY,
                mode: .add,
                onCancel: { pressLocation = nil },
                onSave: { title, start, end in
                    blocks.append((title: title, range: start...(end - 1)))
                    pressLocation = nil
                }
            )
            .presentationDetents([.large])
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
            TimeBlockEditor(
                title: identified.title,
                start: identified.range.lowerBound,
                end: identified.range.upperBound + 1,
                maxY: maxY,
                mode: .edit,
                onCancel: {
                    selectedBlock = nil
                },
                onSave: { newTitle, newStart, newEnd in
                    if let idx = blocks.firstIndex(where: { $0.title == identified.title && $0.range == identified.range }) {
                        blocks[idx].title = newTitle
                        blocks[idx].range = newStart...(newEnd - 1)
                    }
                    selectedBlock = nil
                },
                onDelete: {
                    if let idx = blocks.firstIndex(where: { $0.title == identified.title && $0.range == identified.range }) {
                        blocks.remove(at: idx)
                    }
                    selectedBlock = nil
                }
            )
            .presentationDetents([.large])
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

private enum TimeBlockEditorMode {
    case add
    case edit
}

private struct TimeBlockEditor: View {
    @State private var workingTitle: String
    @State private var workingStart: Int
    @State private var workingEnd: Int

    let maxY: Int
    let mode: TimeBlockEditorMode
    let onCancel: () -> Void
    let onSave: (_ title: String, _ start: Int, _ end: Int) -> Void
    let onDelete: (() -> Void)?

    init(
        title: String,
        start: Int,
        end: Int,
        maxY: Int,
        mode: TimeBlockEditorMode,
        onCancel: @escaping () -> Void,
        onSave: @escaping (_ title: String, _ start: Int, _ end: Int) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        _workingTitle = State(initialValue: title)
        _workingStart = State(initialValue: start)
        _workingEnd = State(initialValue: end)
        self.maxY = maxY
        self.mode = mode
        self.onCancel = onCancel
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $workingTitle)
                }
                Section(header: Text("Time Range"), footer: Text("End is exclusive")) {
                    // Start row with TextField + Stepper
                    HStack {
                        Text("Start")
                        Spacer()
                        TextField("0", text: Binding(
                            get: { String(workingStart) },
                            set: { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let val = Int(filtered) {
                                    // Clamp to allowed range [0, workingEnd - 1]
                                    workingStart = min(max(0, val), max(0, workingEnd - 1))
                                } else if newValue.isEmpty {
                                    // allow clearing temporarily; set to 0 to avoid invalid state
                                    workingStart = 0
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 56)
                        .monospacedDigit()
                        Stepper("", value: $workingStart, in: 0...max(0, workingEnd - 1), step: 1)
                            .labelsHidden()
                            .accessibilityLabel("Increment or decrement start")
                    }

                    // End row with TextField + Stepper
                    HStack {
                        Text("End")
                        Spacer()
                        TextField("1", text: Binding(
                            get: { String(workingEnd) },
                            set: { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let val = Int(filtered) {
                                    // Clamp to allowed range [workingStart + 1, maxY]
                                    let lower = workingStart + 1
                                    workingEnd = min(max(lower, val), max(maxY, lower))
                                } else if newValue.isEmpty {
                                    // allow clearing temporarily; set to minimum allowed
                                    workingEnd = workingStart + 1
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 56)
                        .monospacedDigit()
                        Stepper("", value: $workingEnd, in: (workingStart + 1)...max(maxY, workingStart + 1), step: 1)
                            .labelsHidden()
                            .accessibilityLabel("Increment or decrement end")
                    }
                }

                if let onDelete {
                    Section {
                        Button(role: .destructive) { onDelete() } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add Time Block" : "Edit Time Block")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .add ? "Add" : "Save") {
                        let clampedStart = max(0, min(workingStart, workingEnd - 1))
                        let clampedEnd = max(clampedStart + 1, min(workingEnd, maxY))
                        onSave(workingTitle.trimmingCharacters(in: .whitespacesAndNewlines), clampedStart, clampedEnd)
                    }
                    .disabled(workingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

