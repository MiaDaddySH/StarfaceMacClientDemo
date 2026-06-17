//
//  NotificationService.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Foundation
import UserNotifications

protocol NotificationServicing {

    func requestAuthorization() async -> Bool
    func showIncomingCallNotification(from contact: Contact) async
}

final class NotificationService: NotificationServicing {

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func showIncomingCallNotification(from contact: Contact) async {
        let isAuthorized = await requestAuthorization()

        guard isAuthorized else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Incoming call"
        content.body = "\(contact.name) is calling \(contact.phoneNumber)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "incoming-call-\(contact.id.uuidString)",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
