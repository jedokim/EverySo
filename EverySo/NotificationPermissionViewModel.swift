//
//  NotificationPermissionViewModel.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import Foundation
import UserNotifications

class NotificationPermissionViewModel: ObservableObject {
    @Published var shouldShowPermissionPrompt = true  // set to false after first prompt

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
}
