//
//  NotificationManager.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/28/24.
//

import Foundation

import UserNotifications

class NotificationManager: ObservableObject{
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func sendLocationUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "New Facts Available!"
        content.body = "Check out new historical facts based on your current location."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
