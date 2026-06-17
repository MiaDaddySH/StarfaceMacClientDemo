//
//  CallState.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

enum CallState: Equatable {
    case idle
    case ringing(contact: Contact)
    case dialing(contact: Contact)
    case connecting(contact: Contact)
    case active(contact: Contact, startedAt: Date)
    case held(contact: Contact)
    case ended(reason: CallEndReason)
}

enum CallEndReason: String, Equatable {
    case localEnded = "Local ended"
    case remoteEnded = "Remote ended"
    case missed = "Missed"
    case failed = "Failed"
}
