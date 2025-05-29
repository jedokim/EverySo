//
//  AddEntryView.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import SwiftData
import SwiftUI


struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Holds the entry being edited (nil when adding a new one)
    var entryToEdit: CountdownEntry?

    // State fields prefilled by initializer
    @State private var title: String
    @State private var description: String
    @State private var intervalDays: Int
    @State private var intervalHours: Int
    @State private var intervalMinutes: Int
    @State private var notifyOnReady: Bool

    init(entryToEdit: CountdownEntry? = nil) {
        self.entryToEdit = entryToEdit
        _title = State(initialValue: entryToEdit?.title ?? "")
        _description = State(initialValue: entryToEdit?.details ?? "")
        let days = entryToEdit?.intervalDays ?? 0
        _intervalDays = State(initialValue: days)
        _intervalHours = State(initialValue: 0)
        _intervalMinutes = State(initialValue: 0)
        _notifyOnReady = State(initialValue: entryToEdit?.notifyOnReady ?? false)
    }

    var body: some View {
        Form {
            Section(header: Text("New Countdown")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                Stepper("Days: \(intervalDays)", value: $intervalDays, in: 0...365)
                Stepper("Hours: \(intervalHours)", value: $intervalHours, in: 0...23)
                Stepper("Minutes: \(intervalMinutes)", value: $intervalMinutes, in: 0...59)
                Toggle("Remind me when ready", isOn: $notifyOnReady)
            }

            Button(entryToEdit == nil ? "Add Entry" : "Save Changes") {
                let totalIntervalInSeconds = TimeInterval(intervalDays * 86400 + intervalHours * 3600 + intervalMinutes * 60)
                let totalIntervalInDays = Int(totalIntervalInSeconds / 86400)
                if let existing = entryToEdit {
                    existing.title = title
                    existing.details = description
                    existing.intervalDays = totalIntervalInDays
                    existing.notifyOnReady = notifyOnReady
                } else {
                    let newEntry = CountdownEntry(title: title, description: description, intervalDays: totalIntervalInDays)
                    newEntry.notifyOnReady = notifyOnReady
                    modelContext.insert(newEntry)
                }
                do {
                    try modelContext.save()
                } catch {
                    print("Failed to save: \(error)")
                }
                dismiss()
            }
            .disabled(title.isEmpty)
        }
        .navigationTitle(entryToEdit == nil ? "Add Entry" : "Edit Entry")
    }
}
