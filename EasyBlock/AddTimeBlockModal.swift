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
    /// Callback when user taps Save with valid values
    var onSave: (String, Int, Int) -> Void

    @State private var title: String = ""
    @State private var workingStart: Int = 0
    @State private var workingEnd: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("e.g. Morning Focus", text: $title)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
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
                                    workingStart = min(max(0, val), max(0, workingEnd - 1))
                                } else if newValue.isEmpty {
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
                                    let lower = workingStart + 1
                                    workingEnd = min(max(lower, val), max(maxY, lower))
                                } else if newValue.isEmpty {
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
            }
            .navigationTitle("Add Time Block")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                let suggested = Int(pressLocation.y)
                let clampedStart = max(0, min(suggested, max(maxY - 1, 0)))
                let defaultEnd = min(maxY, clampedStart + 1)
                if workingStart == 0 && workingEnd == 1 { // only set if still default
                    workingStart = clampedStart
                    workingEnd = defaultEnd
                }
            }
        }
    }

    private func saveAndDismiss() {
        let clampedStart = max(0, min(workingStart, workingEnd - 1))
        let clampedEnd = max(clampedStart + 1, min(workingEnd, maxY))
        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), clampedStart, clampedEnd)
        isPresented = false
    }
}
