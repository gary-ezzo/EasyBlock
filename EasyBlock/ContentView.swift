//
//  ContentView.swift
//  EasyBlock
//
//  Created by gary ezzo on 1/13/26.
//

import SwiftUI

struct Block: Identifiable {
    let id = UUID()
    var color: Color
    var width: CGFloat
    var height: CGFloat
    var position: CGPoint

    static func randomColor() -> Color {
        Color(
            red: Double.random(in: 0.2...0.9),
            green: Double.random(in: 0.2...0.9),
            blue: Double.random(in: 0.2...0.9)
        )
    }
}

struct ContentView: View {
    @State private var blocks: [Block] = []
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var showingSizePopup = false
    @State private var heightInput = "100"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ForEach($blocks) { $block in
                    Rectangle()
                        .fill(block.color)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .frame(width: block.width * currentScale * finalScale,
                               height: block.height * currentScale * finalScale)
                        .position(block.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    block.position = value.location
                                }
                        )
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingSizePopup = true }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(24)
                    }
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = value
                    }
                    .onEnded { value in
                        finalScale *= value
                        finalScale = min(max(finalScale, 1.0), 5.0)
                        currentScale = 1.0
                    }
            )
            .alert("New Rectangle", isPresented: $showingSizePopup) {
                TextField("Height", text: $heightInput)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addBlock(in: geometry.size)
                }
            } message: {
                Text("Enter the height for the new rectangle")
            }
        }
    }

    private func addBlock(in size: CGSize) {
        let height = CGFloat(Double(heightInput) ?? 100)
        let centerPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        blocks.append(Block(
            color: Block.randomColor(),
            width: size.width,
            height: height,
            position: centerPosition
        ))
    }
}

#Preview {
    ContentView()
}
