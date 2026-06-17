//
//  CallStateMachine.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

final class CallStateMachine {

    private(set) var state: CallState = .idle

    func startOutgoingCall(to contact: Contact) throws {
        guard case .idle = state else {
            throw CallStateError.invalidTransition(from: state)
        }

        state = .dialing(contact: contact)
    }

    func receiveIncomingCall(from contact: Contact) throws {
        guard case .idle = state else {
            throw CallStateError.invalidTransition(from: state)
        }

        state = .ringing(contact: contact)
    }

    func markConnecting() throws {
        switch state {
        case .dialing(let contact), .ringing(let contact):
            state = .connecting(contact: contact)
        default:
            throw CallStateError.invalidTransition(from: state)
        }
    }

    func markActive() throws {
        switch state {
        case .connecting(let contact):
            state = .active(contact: contact, startedAt: Date())
        default:
            throw CallStateError.invalidTransition(from: state)
        }
    }

    func hold() throws {
        switch state {
        case .active(let contact, _):
            state = .held(contact: contact)
        default:
            throw CallStateError.invalidTransition(from: state)
        }
    }

    func resume() throws {
        switch state {
        case .held(let contact):
            state = .active(contact: contact, startedAt: Date())
        default:
            throw CallStateError.invalidTransition(from: state)
        }
    }

    func end(reason: CallEndReason) {
        state = .ended(reason: reason)
    }

    func reset() {
        state = .idle
    }
}

enum CallStateError: Error {
    case invalidTransition(from: CallState)
}
