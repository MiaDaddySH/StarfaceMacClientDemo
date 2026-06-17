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
    private let notificationService: NotificationServicing
    private var callProgressTask: Task<Void, Never>?
    private var currentCallDirection: CallDirection?

    @Published private(set) var selectedContact: Contact?
    @Published private(set) var currentState: CallState = .idle
    @Published private(set) var lastErrorMessage: String?

    init() {
        self.stateMachine = CallStateMachine()
        self.notificationService = NotificationService()
        currentState = stateMachine.state
    }

    init(stateMachine: CallStateMachine) {
        self.stateMachine = stateMachine
        self.notificationService = NotificationService()
        currentState = stateMachine.state
    }

    init(
        stateMachine: CallStateMachine,
        notificationService: NotificationServicing
    ) {
        self.stateMachine = stateMachine
        self.notificationService = notificationService
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
        currentCallDirection = .outgoing
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

    func simulateIncomingCall() {
        guard let selectedContact else {
            lastErrorMessage = "Select a contact before simulating an incoming call."
            return
        }

        callProgressTask?.cancel()
        lastErrorMessage = nil

        do {
            try stateMachine.receiveIncomingCall(from: selectedContact)
            currentCallDirection = .incoming
            syncState()

            Task {
                await notificationService.showIncomingCallNotification(from: selectedContact)
            }
        } catch {
            lastErrorMessage = "Unable to receive incoming call."
        }
    }

    func answerIncomingCall() {
        callProgressTask?.cancel()
        lastErrorMessage = nil

        do {
            try markConnecting()

            callProgressTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 800_000_000)

                guard let self, !Task.isCancelled else {
                    return
                }

                try? self.markActive()
            }
        } catch {
            lastErrorMessage = "Unable to answer incoming call."
        }
    }

    func rejectIncomingCall() {
        callProgressTask?.cancel()
        onCallCompleted?(makeMissedCallRecord())
        stateMachine.end(reason: .missed)
        syncState()
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
        currentCallDirection = nil
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
        case .dialing, .connecting, .active, .held:
            return true
        case .idle, .ended:
            return false
        case .ringing:
            return false
        }
    }

    var canSimulateIncomingCall: Bool {
        canStartCall
    }

    var canAnswerIncomingCall: Bool {
        if case .ringing = currentState {
            return true
        }

        return false
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
            direction: currentCallDirection ?? .outgoing,
            timestamp: Date(),
            duration: currentCallDuration
        )
    }

    private func makeMissedCallRecord() -> CallRecord {
        let contact = currentContact ?? selectedContact

        return CallRecord(
            contactName: contact?.name ?? "Unknown Caller",
            phoneNumber: contact?.phoneNumber ?? "Unknown",
            direction: .missed,
            timestamp: Date(),
            duration: nil
        )
    }

    private var currentCallDuration: TimeInterval? {
        guard case .active(_, let startedAt) = currentState else {
            return nil
        }

        return Date().timeIntervalSince(startedAt)
    }

    private var currentContact: Contact? {
        switch currentState {
        case .idle, .ended:
            return nil
        case .ringing(let contact),
                .dialing(let contact),
                .connecting(let contact),
                .active(let contact, _),
                .held(let contact):
            return contact
        }
    }
}

enum CallPanelError: Error {
    case noContactSelected
}
