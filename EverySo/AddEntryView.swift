//
//  AddEntryView.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import SwiftData
import SwiftUI

/// A view for adding or editing a countdown entry.
struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Holds the entry being edited (nil when adding a new one)
    var entryToEdit: CountdownEntry?

    // MARK: - Constants

    private let maxDays = 365
    private let maxHours = 23
    private let maxMinutes = 59

    // MARK: - State Properties

    // Title and Description
    @State private var title: String
    @State private var description: String

    // Interval Components
    @State private var intervalDays: Int
    @State private var intervalHours: Int
    @State private var intervalMinutes: Int

    // Settings
    @State private var notifyOnReady: Bool
    @State private var resetOnSave: Bool

    // Alert state
    @State private var showZeroTimeAlert = false

    /// Initializes the view with an optional entry to edit.
    init(entryToEdit: CountdownEntry? = nil) {
        self.entryToEdit = entryToEdit
        _title = State(initialValue: entryToEdit?.title ?? "")
        _description = State(initialValue: entryToEdit?.details ?? "")
        _intervalDays = State(initialValue: entryToEdit?.intervalDays ?? 0)
        _intervalHours = State(initialValue: entryToEdit?.intervalHours ?? 0)
        _intervalMinutes = State(initialValue: entryToEdit?.intervalMinutes ?? 0)
        _notifyOnReady = State(initialValue: entryToEdit?.notifyOnReady ?? false)
        _resetOnSave = State(initialValue: entryToEdit?.resetOnSave ?? false)
    }

    var body: some View {
        Form {
            countdownSection

            Button(entryToEdit == nil ? "Add Entry" : "Save Changes") {
                let totalSeconds = totalIntervalInSeconds()
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
                    existing.resetOnSave = resetOnSave
                    if resetOnSave {
                        existing.lastReset = Date()
                    }
                } else {
                    let newEntry = CountdownEntry(
                        title: title,
                        description: description,
                        intervalDays: intervalDays,
                        intervalHours: intervalHours,
                        intervalMinutes: intervalMinutes
                    )
                    newEntry.notifyOnReady = notifyOnReady
                    newEntry.resetOnSave = resetOnSave
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

    // MARK: - Private Helpers

    /// Computes the total interval in seconds based on days, hours, and minutes.
    private func totalIntervalInSeconds() -> Int {
        return intervalDays * 86400 + intervalHours * 3600 + intervalMinutes * 60
    }

    // MARK: - View Components

    /// The section containing the countdown input fields.
    private var countdownSection: some View {
        Section(header: Text(entryToEdit == nil ? "New Countdown" : "Edit Countdown")) {
            // Title and Description
            TextField("Title", text: $title)
            TextField("Description", text: $description)

            // Interval pickers
            Stepper("Days: \(intervalDays)", value: $intervalDays, in: 0...maxDays)
            Stepper("Hours: \(intervalHours)", value: $intervalHours, in: 0...maxHours)
            Stepper("Minutes: \(intervalMinutes)", value: $intervalMinutes, in: 0...maxMinutes)

            // Settings toggles
            Toggle("Remind me when ready", isOn: $notifyOnReady)
            Toggle("Reset on save", isOn: $resetOnSave)
        }
    }
}
