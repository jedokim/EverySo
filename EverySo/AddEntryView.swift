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
    @State private var intervalDays = 30

    var body: some View {
        Form {
            Section(header: Text("New Countdown")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                Stepper("Every \(intervalDays) days", value: $intervalDays, in: 1...365)
            }

            Button("Add") {
                let newEntry = CountdownEntry(title: title, description: description, intervalDays: intervalDays)
                modelContext.insert(newEntry)
                dismiss()
            }
            .disabled(title.isEmpty)
        }
        .navigationTitle("Add Entry")
    }
}
