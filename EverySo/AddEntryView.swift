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

    @State private var title = ""
    @State private var description = ""
    @State private var intervalDays = 0
    @State private var intervalHours = 0
    @State private var intervalMinutes = 0
    @State private var notifyOnReady = false

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

            Button("Add") {
                let totalIntervalInSeconds = TimeInterval(intervalDays * 86400 + intervalHours * 3600 + intervalMinutes * 60)
                let totalIntervalInDays = Int(totalIntervalInSeconds / 86400)
                let newEntry = CountdownEntry(title: title, description: description, intervalDays: totalIntervalInDays)
                newEntry.notifyOnReady = notifyOnReady
                modelContext.insert(newEntry)
                dismiss()
            }
            .disabled(title.isEmpty)
        }
        .navigationTitle("Add Entry")
    }
}
