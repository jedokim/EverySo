//
//  SidebarContainerView.swift
//  EverySo
//
//  Created by Jeremy Kim on 6/11/25.
//

import Foundation
import SwiftUI

struct SidebarContainerView: View {
    @Binding var isSidebarVisible: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if isSidebarVisible {
                // Dimmed background overlay
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSidebarVisible = false
                        }
                    }
            }

            // The sliding sidebar
            SideBarView()
                .frame(width: 250)
                .background(Color(.systemGray6))
                .offset(x: isSidebarVisible ? 0 : -250)
                .opacity(isSidebarVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isSidebarVisible)
        }
    }
}

struct SideBarView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Menu")
                .font(.headline)
                .padding(.top, 100)
            Divider()
            Button("First Option") { }
                .padding(.vertical, 10)
            Button("Second Option") { }
                .padding(.vertical, 10)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}
