//
//  CountdownEntry.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import Foundation
import SwiftUI
import SwiftData
import UserNotifications

@Model
class CountdownEntry {
    var id: UUID = UUID()
    var title: String
    var details: String
    var lastReset: Date
    var intervalDays: Int
    var notifyOnReady: Bool = false

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
    
    var countdownInterval: TimeInterval {
        return TimeInterval(intervalDays * 86400) // days → seconds
    }
    
    var timeRemainingFormatted: String {
        let now = Date()
        let nextDate = lastReset.addingTimeInterval(countdownInterval)
        let remaining = max(0, nextDate.timeIntervalSince(now))
        
        let days = Int(remaining) / 86400
        let hours = (Int(remaining) % 86400) / 3600
        let minutes = (Int(remaining) % 3600) / 60

        return "\(days)d \(hours)h \(minutes)m left"
    }
    
    func scheduleNotification() {
        guard notifyOnReady else { return }

        let content = UNMutableNotificationContent()
        content.title = "EverySo Reminder"
        content.body = "“\(title)” is ready again!"
        content.sound = .default

        let triggerDate = nextAvailableDate
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}
