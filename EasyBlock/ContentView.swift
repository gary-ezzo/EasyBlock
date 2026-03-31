//
//  ContentView.swift
//  EasyBlock
//
//  Created by gary ezzo on 1/13/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showModal = false
    
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
            .onLongPressGesture(minimumDuration: 0.5) {
                showModal = true
            }
        }
        .sheet(isPresented: $showModal) {
            VStack(spacing: 16) {
                Text("Long Press Detected")
                    .font(.title2)
                Button("Dismiss") {
                    showModal = false
                }
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
