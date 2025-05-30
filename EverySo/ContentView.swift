import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [CountdownEntry]
    // Track which entry the user is editing
    @State private var entryToEdit: CountdownEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.headline)
                                Text(entry.details)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
//                                Text("\(entry.daysRemaining) days left")
                                Text("\(entry.intervalDays)d \(entry.intervalHours)h \(entry.intervalMinutes)m")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(entry.timeRemainingFormatted)
                                    .font(.subheadline)
                                ProgressView(value: entry.progress)
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
