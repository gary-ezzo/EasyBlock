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
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Long Press Detected")
                .font(.title2)
            Text("x: \(Int(pressLocation.x)), y: \(Int(pressLocation.y))")
                .monospaced()
            Button("Dismiss") {
                isPresented = false
            }
        }
    }
}
