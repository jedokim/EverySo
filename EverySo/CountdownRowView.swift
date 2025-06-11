//
//  CountdownRowView.swift
//  EverySo
//
//  Created by Jeremy Kim on 6/10/25.
//

/// CountdownRowView displays a countdown entry row with progress, time remaining, reset, and edit functionality.

import SwiftUI

struct CountdownRowView: View {
    let entry: CountdownEntry
    @ObservedObject var clock: Clock
    let isDarkMode: Bool
    @Binding var entryToEdit: CountdownEntry?

    var body: some View {
        let progress = entry.progress(from: clock.now)
        let rowBackground = progress >= 1 ? (isDarkMode ? Color.green.opacity(0.3) : Color.green.opacity(0.2)) : Color.clear

        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.title)
                            if progress >= 1 {
                                Text("(Done)")
                                    .foregroundColor(.green)
                            }
                        }
                        .font(.headline)
                        Text(entry.details)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Progress: \(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .accessibilityLabel("Progress")
                            .accessibilityValue("\(Int(progress * 100)) percent")
                        Text(entry.formattedTimeRemaining(from: clock.now))
                            .font(.subheadline)
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .frame(width: 100)
                    }
                }

                Button("Reset") {
                    entry.resetCountdown()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(rowBackground)
        .swipeActions(edge: .leading) {
            Button("Edit") {
                entryToEdit = entry
            }
            .tint(.blue)
        }
    }
}
