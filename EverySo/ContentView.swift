import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [CountdownEntry]
    @State private var entryToEdit: CountdownEntry?
    @StateObject private var clock = Clock()
    @State private var isDarkMode = false

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
                                    Text("Progress: \(Int(entry.progress(from: clock.now) * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text(entry.formattedTimeRemaining(from: clock.now))
                                        .font(.subheadline)
                                    ProgressView(value: entry.progress(from: clock.now))
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
