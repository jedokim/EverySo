import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [CountdownEntry]
    // Track which entry the user is editing
    @State private var entryToEdit: CountdownEntry?
    @StateObject private var clock = Clock()

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title + (entry.progress >= 1 ? " (Done)" : ""))
                                        .font(.headline)
                                    Text(entry.details)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
//                                Text("\(entry.daysRemaining) days left")
//                                    Text("\(entry.intervalDays)d \(entry.intervalHours)h \(entry.intervalMinutes)m")
//                                    Text("Progress: \(Int(entry.progress(from: clock.now) * 100))%")
//                                        .font(.caption)
//                                        .foregroundColor(.blue)
                                    Text("Progress: \(Int(entry.progress(from: clock.now) * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text(entry.formattedTimeRemaining(from: clock.now))
                                        .font(.subheadline)
                                    ProgressView(value: entry.progress(from: clock.now))
                                        .progressViewStyle(.linear)
                                        .frame(width: 100)
//                                This is for a circular visual icon
//                                ProgressView(value: entry.progress)
//                                    .progressViewStyle(.circular)
//                                    .tint(.blue)
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
                    .listRowBackground(entry.progress >= 1 ? Color.green.opacity(0.1) : Color.clear)
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CountdownEntry.self)
}
