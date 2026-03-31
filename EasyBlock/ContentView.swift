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
        }
    }
}

#Preview {
    ContentView()
}
