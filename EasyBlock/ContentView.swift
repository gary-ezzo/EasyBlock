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

    static func randomColor() -> Color {
        Color(
            red: Double.random(in: 0.2...0.9),
            green: Double.random(in: 0.2...0.9),
            blue: Double.random(in: 0.2...0.9)
        )
    }
}

struct ContentView: View {
    @State private var blocks: [Block] = [Block(color: Block.randomColor())]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(blocks) { block in
                        Rectangle()
                            .fill(block.color)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: addBlock) {
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
        }
        .ignoresSafeArea()
    }

    private func addBlock() {
        blocks.append(Block(color: Block.randomColor()))
    }
}

#Preview {
    ContentView()
}
