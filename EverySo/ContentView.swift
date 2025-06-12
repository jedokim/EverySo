//
//  ContentView.swift
//  EverySo
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
    @State private var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode")
    @State private var isSidebarVisible: Bool = false

    /// Navigation toolbar with theme toggle and add entry button.
    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isDarkMode.toggle()
                    UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
                }) {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.leading")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddEntryView()) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack {
                List {
                    ForEach(entries, id: \.id) { entry in
                        CountdownRowView(entry: entry, clock: clock, isDarkMode: isDarkMode, entryToEdit: $entryToEdit)
                    }
                    .onDelete(perform: deleteEntry)
                }
                .listStyle(.plain)
                .navigationTitle("EverySo")
                .toolbar { toolbar }
                .sheet(item: $entryToEdit) { entry in
                    AddEntryView(entryToEdit: entry)
                }
            }
            .background(Color(isDarkMode ? .black : .white).edgesIgnoringSafeArea(.all))
            .preferredColorScheme(isDarkMode ? .dark : .light)

            ZStack(alignment: .leading) {
                if isSidebarVisible {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSidebarVisible = false
                            }
                        }
                }
                SideBarView()
                    .frame(width: 250)
                    .background(Color(.systemGray6))
                    .offset(x: isSidebarVisible ? 0 : -250)
                    .opacity(isSidebarVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isSidebarVisible)
            }
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CountdownEntry.self)
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
