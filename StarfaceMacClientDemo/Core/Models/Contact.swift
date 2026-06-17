//
//  Contact.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

struct Contact: Identifiable, Equatable {
    let id: UUID
    let name: String
    let department: String
    let phoneNumber: String
    let presenceStatus: PresenceStatus

    init(
        id: UUID = UUID(),
        name: String,
        department: String,
        phoneNumber: String,
        presenceStatus: PresenceStatus
    ) {
        self.id = id
        self.name = name
        self.department = department
        self.phoneNumber = phoneNumber
        self.presenceStatus = presenceStatus
    }
}

enum PresenceStatus: String, Equatable {
    case available = "Available"
    case busy = "Busy"
    case offline = "Offline"
}
