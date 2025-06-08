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

    @State private var intervalDaysString: String
    @State private var intervalHoursString: String
    @State private var intervalMinutesString: String

    // Settings
    @State private var notifyOnReady: Bool
    @State private var resetOnSave: Bool

    // Alert state
    @State private var showZeroTimeAlert = false

    // Focus state for text fields
    @FocusState private var focusedField: Field?

    // Define Focusable Fields
    enum Field: Hashable {
        case title
        case description
        case days
        case hours
        case minutes
    }

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
        _intervalDaysString = State(initialValue: "\(entryToEdit?.intervalDays ?? 0)")
        _intervalHoursString = State(initialValue: "\(entryToEdit?.intervalHours ?? 0)")
        _intervalMinutesString = State(initialValue: "\(entryToEdit?.intervalMinutes ?? 0)")
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
                        existing.resetCountdown()
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
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
                .focused($focusedField, equals: .title)
            TextField("Description", text: $description)
                .focused($focusedField, equals: .description)

            // Days Input
            HStack {
                Text("Days:")
                TextField("Days", text: $intervalDaysString)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .focused($focusedField, equals: .days)
                    .onChange(of: intervalDaysString) {
                        let filtered = intervalDaysString.filter { $0.isNumber }
                        if let intValue = Int(filtered), intValue <= maxDays {
                            intervalDays = intValue
                            intervalDaysString = "\(intValue)"
                        } else if filtered.isEmpty {
                            intervalDays = 0
                            intervalDaysString = "0"
                        } else if let intValue = Int(filtered), intValue > maxDays {
                            intervalDays = maxDays
                            intervalDaysString = "\(maxDays)"
                        }
                    }
                Stepper("", value: $intervalDays, in: 0...maxDays)
                    .onChange(of: intervalDays) {
                        intervalDaysString = "\(intervalDays)"
                    }
            }

            // Hours Input
            HStack {
                Text("Hours:")
                TextField("Hours", text: $intervalHoursString)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .focused($focusedField, equals: .hours)
                    .onChange(of: intervalHoursString) {
                        let filtered = intervalHoursString.filter { $0.isNumber }
                        if let intValue = Int(filtered), intValue <= maxHours {
                            intervalHours = intValue
                            intervalHoursString = "\(intValue)"
                        } else if filtered.isEmpty {
                            intervalHours = 0
                            intervalHoursString = "0"
                        } else if let intValue = Int(filtered), intValue > maxHours {
                            intervalHours = maxHours
                            intervalHoursString = "\(maxHours)"
                        }
                    }
                Stepper("", value: $intervalHours, in: 0...maxHours)
                    .onChange(of: intervalHours) {
                        intervalHoursString = "\(intervalHours)"
                    }
            }

            // Minutes Input
            HStack {
                Text("Minutes:")
                TextField("Minutes", text: $intervalMinutesString)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .focused($focusedField, equals: .minutes)
                    .onChange(of: intervalMinutesString) {
                        let filtered = intervalMinutesString.filter { $0.isNumber }
                        if let intValue = Int(filtered), intValue <= maxMinutes {
                            intervalMinutes = intValue
                            intervalMinutesString = "\(intValue)"
                        } else if filtered.isEmpty {
                            intervalMinutes = 0
                            intervalMinutesString = "0"
                        } else if let intValue = Int(filtered), intValue > maxMinutes {
                            intervalMinutes = maxMinutes
                            intervalMinutesString = "\(maxMinutes)"
                        }
                    }
                Stepper("", value: $intervalMinutes, in: 0...maxMinutes)
                    .onChange(of: intervalMinutes) {
                        intervalMinutesString = "\(intervalMinutes)"
                    }
            }

            // Settings toggles
            Toggle("Remind me when ready", isOn: $notifyOnReady)
            Toggle("Reset on save", isOn: $resetOnSave)
        }
    }
}
