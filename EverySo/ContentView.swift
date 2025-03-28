//
//  ContentView.swift
//  EverySo
//
//  Created by Jeremy Kim on 2/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Image(systemName: "tv.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("EverySo")
                Spacer() // Push content to the top
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
