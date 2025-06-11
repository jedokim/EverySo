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

/// A model representing a countdown entry with a title, details, and interval.
/// Tracks the last reset date and calculates the next available date based on the interval.
/// Supports notifications when the countdown is ready again.
@Model
class CountdownEntry {
    // MARK: - Properties
    
    /// Unique identifier for the countdown entry. Immutable after creation.
    var id: UUID = UUID()
    
    /// Title of the countdown entry.
    var title: String

    /// Detailed description of the countdown entry.
    var details: String

    /// The date when the countdown was last reset.
    var lastReset: Date
    
    /// Number of days for the countdown interval.
    var intervalDays: Int

    /// Number of hours for the countdown interval.
    var intervalHours: Int = 0

    /// Number of minutes for the countdown interval.
    var intervalMinutes: Int = 0

    /// Whether to notify when the countdown is ready.
    var notifyOnReady: Bool = false

    /// Whether to reset the countdown on save.
    var resetOnSave: Bool = false

    // MARK: - Initialization
    
    /// Initializes a new CountdownEntry.
    /// - Parameters:
    ///   - title: The title of the countdown.
    ///   - description: The detailed description.
    ///   - intervalDays: Interval in days.
    ///   - intervalHours: Interval in hours (default 0).
    ///   - intervalMinutes: Interval in minutes (default 0).
    ///   - lastReset: The date of last reset (default current date).
    /// Note: scheduleNotification() is called here to ensure a notification is scheduled when a new CountdownEntry is created.
    ///       If the countdown timer is reset elsewhere, scheduleNotification() should be called after resetting as well.
    init(title: String, description: String, intervalDays: Int, intervalHours: Int = 0, intervalMinutes: Int = 0, lastReset: Date = Date()) {
        self.title = title
        self.details = description
        self.intervalDays = intervalDays
        self.intervalHours = intervalHours
        self.intervalMinutes = intervalMinutes
        self.lastReset = lastReset
        self.scheduleNotification()
    }
    
    // MARK: - Computed Properties
    
    /// The total countdown interval in seconds.
    /// Ensures all interval components are non-negative.
    var countdownInterval: TimeInterval {
        let secondsFromDays = max(intervalDays, 0) * 86400
        let secondsFromHours = max(intervalHours, 0) * 3600
        let secondsFromMinutes = max(intervalMinutes, 0) * 60
        return TimeInterval(secondsFromDays + secondsFromHours + secondsFromMinutes)
    }
    
    /// The next date when the countdown will be available.
    var nextAvailableDate: Date {
        lastReset.addingTimeInterval(countdownInterval)
    }
    
    /// The number of full days remaining until the countdown is ready.
    var daysRemaining: Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: nextAvailableDate).day ?? 0, 0)
    }
    
    /// The number of seconds remaining until the countdown is ready.
    var secondsRemaining: Int {
        let now = Date()
        return max(Int(nextAvailableDate.timeIntervalSince(now)), 0)
    }
    
    /// The progress of the countdown as a value between 0 and 1.
    var progress: Double {
        progress(from: Date())
    }
    
    // MARK: - Time Calculation Methods
    
    /// Calculates the time remaining from a given date.
    /// - Parameter now: The current date to calculate from.
    /// - Returns: Time interval remaining, or zero if passed.
    func timeRemaining(from now: Date) -> TimeInterval {
        let nextResetDate = lastReset.addingTimeInterval(countdownInterval)
        return max(nextResetDate.timeIntervalSince(now), 0)
    }
    
    /// Formats the time remaining from a given date into a user-friendly string.
    /// - Parameter now: The current date to calculate from.
    /// - Returns: A formatted string representing the time left.
    func formattedTimeRemaining(from now: Date) -> String {
        let remaining = timeRemaining(from: now)
        if remaining < 60 {
            let seconds = Int(remaining)
            return "\(seconds)s left"
        } else if remaining < 3600 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            return "\(minutes)m \(seconds)s left"
        } else {
            let days = Int(remaining) / 86400
            let hours = (Int(remaining) % 86400) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            
            var components: [String] = []
            if days > 0 {
                components.append("\(days)d")
            }
            if hours > 0 {
                components.append("\(hours)h")
            }
            components.append("\(minutes)m")
            
            return components.joined(separator: " ") + " left"
        }
    }
    
    /// Calculates the progress of the countdown from a given date.
    /// - Parameter now: The current date to calculate from. Defaults to current date.
    /// - Returns: A Double between 0 and 1 representing progress.
    func progress(from now: Date = Date()) -> Double {
        let total = countdownInterval
        guard total > 0 else { return 1 }
        let elapsed = now.timeIntervalSince(lastReset)
        return min(max(elapsed / total, 0), 1)
    }
    
    // MARK: - Notification
    
    /// Schedules a notification for when the countdown is ready again.
    /// Call this whenever the countdown's lastReset date or interval changes.
    /// For example, after resetting, editing interval, or creating a new CountdownEntry.
    func scheduleNotification() {
        guard notifyOnReady else { return }
        let triggerDate = nextAvailableDate
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "EverySo Reminder"
        content.body = "“\(title)” is ready again!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate),
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

    /// Resets the countdown to now and schedules a notification.
    func resetCountdown() {
        // Remove any existing notification for this countdown
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        
        // Update the last reset date to now
        self.lastReset = Date()
        
        // Schedule a new notification
        scheduleNotification()
    }
}
