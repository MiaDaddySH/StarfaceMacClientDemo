//
//  CallRecord.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

struct CallRecord: Identifiable, Equatable {
    let id: UUID
    let contactName: String
    let phoneNumber: String
    let direction: CallDirection
    let timestamp: Date
    let duration: TimeInterval?

    init(
        id: UUID = UUID(),
        contactName: String,
        phoneNumber: String,
        direction: CallDirection,
        timestamp: Date,
        duration: TimeInterval?
    ) {
        self.id = id
        self.contactName = contactName
        self.phoneNumber = phoneNumber
        self.direction = direction
        self.timestamp = timestamp
        self.duration = duration
    }
}

enum CallDirection: String, Equatable {
    case incoming = "Incoming"
    case outgoing = "Outgoing"
    case missed = "Missed"
}
