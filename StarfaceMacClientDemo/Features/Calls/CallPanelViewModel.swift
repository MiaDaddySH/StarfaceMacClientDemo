//
//  CallPanelViewModel.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Combine
import Foundation

@MainActor
final class CallPanelViewModel: ObservableObject {

    var onCallCompleted: ((CallRecord) -> Void)?

    private let stateMachine: CallStateMachine
    private var callProgressTask: Task<Void, Never>?

    @Published private(set) var selectedContact: Contact?
    @Published private(set) var currentState: CallState = .idle
    @Published private(set) var lastErrorMessage: String?

    init() {
        self.stateMachine = CallStateMachine()
        currentState = stateMachine.state
    }

    init(stateMachine: CallStateMachine) {
        self.stateMachine = stateMachine
        currentState = stateMachine.state
    }

    func select(contact: Contact) {
        selectedContact = contact

        if case .ended = currentState {
            resetCall()
        }
    }

    func startCall() throws {
        guard let selectedContact else {
            throw CallPanelError.noContactSelected
        }

        try stateMachine.startOutgoingCall(to: selectedContact)
        syncState()
    }

    func startDemoCallFlow() {
        callProgressTask?.cancel()
        lastErrorMessage = nil

        do {
            try startCall()

            callProgressTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                guard let self, !Task.isCancelled else {
                    return
                }

                try? self.markConnecting()

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                guard !Task.isCancelled else {
                    return
                }

                try? self.markActive()
            }
        } catch {
            lastErrorMessage = "Unable to start call."
        }
    }

    func markConnecting() throws {
        try stateMachine.markConnecting()
        syncState()
    }

    func markActive() throws {
        try stateMachine.markActive()
        syncState()
    }

    func endCall() {
        callProgressTask?.cancel()

        if let completedCallRecord = makeCompletedCallRecord() {
            onCallCompleted?(completedCallRecord)
        }

        stateMachine.end(reason: .localEnded)
        syncState()
    }

    func resetCall() {
        callProgressTask?.cancel()
        stateMachine.reset()
        syncState()
    }

    var canStartCall: Bool {
        guard selectedContact != nil else {
            return false
        }

        if case .idle = currentState {
            return true
        }

        return false
    }

    var canEndCall: Bool {
        switch currentState {
        case .dialing, .connecting, .active, .held, .ringing:
            return true
        case .idle, .ended:
            return false
        }
    }

    private func syncState() {
        currentState = stateMachine.state
    }

    private func makeCompletedCallRecord() -> CallRecord? {
        guard let selectedContact else {
            return nil
        }

        return CallRecord(
            contactName: selectedContact.name,
            phoneNumber: selectedContact.phoneNumber,
            direction: .outgoing,
            timestamp: Date(),
            duration: currentCallDuration
        )
    }

    private var currentCallDuration: TimeInterval? {
        guard case .active(_, let startedAt) = currentState else {
            return nil
        }

        return Date().timeIntervalSince(startedAt)
    }
}

enum CallPanelError: Error {
    case noContactSelected
}
