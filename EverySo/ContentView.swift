//
//  EverySoTests.swift
//  EverySoTests
//
//  Created by Jeremy Kim on 2/20/25.
//

import SwiftUI
import SwiftData

/// The main view displaying a list of countdown entries with progress tracking and editing capabilities.
struct ContentView: View {
    // MARK: - Environment and State
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [CountdownEntry]
    
    @State private var entryToEdit: CountdownEntry?
    @StateObject private var clock = Clock()
    @State private var isDarkMode = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    let progress = entry.progress(from: clock.now)
                    let rowBackground = progress >= 1 ? (isDarkMode ? Color.green.opacity(0.3) : Color.green.opacity(0.2)) : Color.clear
                    
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title + (progress >= 1 ? " (Done)" : ""))
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
                                    Text(entry.formattedTimeRemaining(from: clock.now))
                                        .font(.subheadline)
                                    ProgressView(value: progress)
                                        .progressViewStyle(.linear)
                                        .frame(width: 100)
                                }
                            }

                            Button("Reset") {
                                entry.lastReset = Date()
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
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(entries[index])
                    }
                }
            }
            .navigationTitle("EverySo")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEntryView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Present AddEntryView when editing an entry
            .sheet(item: $entryToEdit) { entry in
                AddEntryView(entryToEdit: entry)
            }
        }
        .background(Color(isDarkMode ? .black : .white).edgesIgnoringSafeArea(.all))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CountdownEntry.self)
}
