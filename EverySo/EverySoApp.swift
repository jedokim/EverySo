//
//  EverySoApp.swift
//  EverySo
//
//  Created by Jeremy Kim on 2/20/25.
//

import SwiftUI
import UserNotifications

@main
struct EverySoApp: App {
    @StateObject private var permissionVM = NotificationPermissionViewModel()

    var body: some Scene {
        WindowGroup {
            PermissionPromptView()
                .environmentObject(permissionVM)
        }
    }
}

struct PermissionPromptView: View {
    @EnvironmentObject var permissionVM: NotificationPermissionViewModel

    var body: some View {
        ContentView()
            .modelContainer(for: CountdownEntry.self)
            .alert("Enable Notifications?", isPresented: $permissionVM.shouldShowPermissionPrompt) {
                Button("Allow") {
                    permissionVM.requestNotificationPermission()
                    permissionVM.shouldShowPermissionPrompt = false
                }
                Button("Not Now", role: .cancel) {
                    permissionVM.shouldShowPermissionPrompt = false
                }
            } message: {
                Text("EverySo uses notifications to remind you when your timers are ready. You can always change this later in Settings.")
            }
    }
}
