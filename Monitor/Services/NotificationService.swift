//
//  NotificationService.swift
//  Monitor
//
//  Handles scheduling and managing local notifications for daily review reminders
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "review-time-reminder"

    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Scheduling

    func scheduleReviewTimeReminder(at time: Date) {
        // Cancel existing notification first
        cancelReviewTimeReminder()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Review"
        content.body = "Time to reflect on your day's meals and eating patterns"
        content.sound = .default
        content.categoryIdentifier = "REVIEW_TIME"

        // Extract hour and minute from the date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Create trigger to fire daily at the specified time
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Review time reminder scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
            }
        }
    }

    func cancelReviewTimeReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("Review time reminder cancelled")
    }

    // MARK: - Testing

    #if DEBUG
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification that will fire in 5 seconds"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            } else {
                print("Test notification scheduled for 5 seconds from now")
            }
        }
    }
    #endif
}
