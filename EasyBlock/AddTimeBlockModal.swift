//
//  AddTimeBlockModal.swift
//  EasyBlock
//
//  Created by gary ezzo on 7/28/26.
//

import SwiftUI

struct AddTimeBlockModal: View {
    let pressLocation: CGPoint
    @Binding var isPresented: Bool
    /// The maximum Y coordinate available in ContentView (inclusive)
    let maxY: Int
    /// Optional existing values when editing an existing block
    let existing: (id: UUID?, title: String, start: Int, end: Int)?
    /// Callback when user taps Save with valid values
    var onSave: (_ id: UUID?, _ title: String, _ start: Int, _ end: Int) -> Void

    @State private var startText: String = ""
    @State private var endText: String = ""
    @State private var title: String = ""

    // Derived integer values with clamping
    private var startValue: Int {
        let raw = Int(startText) ?? 0
        return max(0, min(raw, max(maxY - 1, 0)))
    }

    private var endValue: Int {
        let raw = Int(endText) ?? 0
        return max(0, min(raw, maxY))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Press Location")) {
                    HStack {
                        Text("x:")
                        Text("\(Int(pressLocation.x))")
                            .monospaced()
                        Spacer()
                        Text("y:")
                        Text("\(Int(pressLocation.y))")
                            .monospaced()
                    }
                }

                Section(header: Text("Title")) {
                    TextField("e.g. Morning Focus", text: $title)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                }

                Section(header: Text("Start Time")) {
                    TextField("0", text: $startText)
                        .keyboardType(.numberPad)
                        .onChange(of: startText) { _, _ in
                            enforceOrderingAfterStartChange()
                        }
                    Text("Min 0, Max \(max(maxY - 1, 0))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("End Time")) {
                    TextField("0", text: $endText)
                        .keyboardType(.numberPad)
                        .onChange(of: endText) { _, _ in
                            enforceOrderingAfterEndChange()
                        }
                    Text("Min 0, Max \(maxY)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                if let existing = existing {
                    title = existing.title
                    startText = String(existing.start)
                    endText = String(existing.end)
                } else {
                    // Default to press location when adding
                    if startText.isEmpty { startText = String(Int(pressLocation.y)) }
                    if endText.isEmpty { endText = String(Int(pressLocation.y)) }
                }
            }
            .navigationTitle(existing == nil ? "Add Time Block" : "Edit Time Block")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                        .disabled(!isValidRange || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var isValidRange: Bool {
        // Recompute with clamped values and ordering
        let (s, e) = orderedClampedValues()
        return s >= 0 && e >= 0 && s <= max(maxY - 1, 0) && e <= maxY && s < e
    }

    private func orderedClampedValues() -> (Int, Int) {
        var s = startValue
        var e = endValue
        if s >= e { e = min(maxY, s + 1) }
        if e <= s { s = max(0, e - 1) }
        return (s, e)
    }

    private func enforceOrderingAfterStartChange() {
        // Clamp start into range
        let clampedStart = startValue
        if clampedStart >= endValue {
            endText = String(min(maxY, clampedStart + 1))
        }
        // Also ensure text reflects clamped value if out of bounds
        if Int(startText) != clampedStart { startText = String(clampedStart) }
    }

    private func enforceOrderingAfterEndChange() {
        // Clamp end into range
        let clampedEnd = endValue
        if clampedEnd <= startValue {
            startText = String(max(0, clampedEnd - 1))
        }
        // Also ensure text reflects clamped value if out of bounds
        if Int(endText) != clampedEnd { endText = String(clampedEnd) }
    }

    private func saveAndDismiss() {
        let (s, e) = orderedClampedValues()
        onSave(existing?.id, title.trimmingCharacters(in: .whitespacesAndNewlines), s, e)
        isPresented = false
    }
}

