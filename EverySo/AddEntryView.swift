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
    @State private var showZeroTimeAlert = false

    init(entryToEdit: CountdownEntry? = nil) {
        self.entryToEdit = entryToEdit
        _title = State(initialValue: entryToEdit?.title ?? "")
        _description = State(initialValue: entryToEdit?.details ?? "")
        _intervalDays = State(initialValue: entryToEdit?.intervalDays ?? 0)
        _intervalHours = State(initialValue: entryToEdit?.intervalHours ?? 0)
        _intervalMinutes = State(initialValue: entryToEdit?.intervalMinutes ?? 0)
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
                let totalSeconds = intervalDays * 86400 + intervalHours * 3600 + intervalMinutes * 60
                guard totalSeconds > 0 else {
                    showZeroTimeAlert = true
                    return
                }
                if let existing = entryToEdit {
                    existing.title = title
                    existing.details = description
                    existing.intervalDays = intervalDays
                    existing.intervalHours = intervalHours
                    existing.intervalMinutes = intervalMinutes
                    existing.notifyOnReady = notifyOnReady
                } else {
                    let newEntry = CountdownEntry(
                        title: title,
                        description: description,
                        intervalDays: intervalDays,
                        intervalHours: intervalHours,
                        intervalMinutes: intervalMinutes
                    )
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
        .alert("Countdown interval must be greater than zero.", isPresented: $showZeroTimeAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle(entryToEdit == nil ? "Add Entry" : "Edit Entry")
    }
}
