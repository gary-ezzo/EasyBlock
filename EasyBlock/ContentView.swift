//
//  ContentView.swift
//  EasyBlock
//
//  Created by gary ezzo on 1/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                ForEach(0..<24, id: \.self) { _ in
                    Divider()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
