//
//  CountdownEntry.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class CountdownEntry {
    var title: String
    var details: String
    var lastReset: Date
    var intervalDays: Int

    init(title: String, description: String, intervalDays: Int, lastReset: Date = Date()) {
        self.title = title
        self.details = description
        self.intervalDays = intervalDays
        self.lastReset = lastReset
    }

    var nextAvailableDate: Date {
        Calendar.current.date(byAdding: .day, value: intervalDays, to: lastReset) ?? Date()
    }

    var daysRemaining: Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: nextAvailableDate).day ?? 0, 0)
    }
    
    var progress: Double {
        let elapsed = Date().timeIntervalSince(lastReset)
        let total = Double(intervalDays * 86400) // days → seconds
        return min(max(elapsed / total, 0), 1)
    }
}
