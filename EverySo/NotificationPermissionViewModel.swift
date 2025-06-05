//
//  NotificationPermissionViewModel.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/28/25.
//

import Foundation
import UserNotifications

class NotificationPermissionViewModel: ObservableObject {
    @Published var shouldShowPermissionPrompt = false

    init() {
        checkNotificationPermission()
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.shouldShowPermissionPrompt = true
                default:
                    self.shouldShowPermissionPrompt = false
                }
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
            // After requesting, update permission prompt state
            self.checkNotificationPermission()
        }
    }
}
