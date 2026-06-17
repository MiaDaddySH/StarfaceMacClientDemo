//
//  StarfaceMacClientDemoTests.swift
//  StarfaceMacClientDemoTests
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Testing
@testable import StarfaceMacClientDemo

struct CallStateMachineTests {

    @Test
    func outgoingCallProgressesToActive() throws {
        let stateMachine = CallStateMachine()
        let contact = makeContact()

        try stateMachine.startOutgoingCall(to: contact)
        #expect(stateMachine.state == .dialing(contact: contact))

        try stateMachine.markConnecting()
        #expect(stateMachine.state == .connecting(contact: contact))

        try stateMachine.markActive()

        guard case .active(let activeContact, _) = stateMachine.state else {
            Issue.record("Expected active call state.")
            return
        }

        #expect(activeContact == contact)
    }

    @Test
    func incomingCallProgressesToActive() throws {
        let stateMachine = CallStateMachine()
        let contact = makeContact()

        try stateMachine.receiveIncomingCall(from: contact)
        #expect(stateMachine.state == .ringing(contact: contact))

        try stateMachine.markConnecting()
        #expect(stateMachine.state == .connecting(contact: contact))

        try stateMachine.markActive()

        guard case .active(let activeContact, _) = stateMachine.state else {
            Issue.record("Expected active call state.")
            return
        }

        #expect(activeContact == contact)
    }

    @Test
    func activeCallCanBeHeldAndResumed() throws {
        let stateMachine = CallStateMachine()
        let contact = makeContact()

        try stateMachine.startOutgoingCall(to: contact)
        try stateMachine.markConnecting()
        try stateMachine.markActive()

        try stateMachine.hold()
        #expect(stateMachine.state == .held(contact: contact))

        try stateMachine.resume()

        guard case .active(let activeContact, _) = stateMachine.state else {
            Issue.record("Expected active call state after resume.")
            return
        }

        #expect(activeContact == contact)
    }

    @Test
    func invalidTransitionThrows() throws {
        let stateMachine = CallStateMachine()

        #expect(throws: CallStateError.self) {
            try stateMachine.markActive()
        }
    }

    @Test
    func endAndResetReturnToIdle() throws {
        let stateMachine = CallStateMachine()
        let contact = makeContact()

        try stateMachine.startOutgoingCall(to: contact)
        stateMachine.end(reason: .localEnded)
        #expect(stateMachine.state == .ended(reason: .localEnded))

        stateMachine.reset()
        #expect(stateMachine.state == .idle)
    }

    private func makeContact() -> Contact {
        Contact(
            name: "Anna Keller",
            department: "Sales",
            phoneNumber: "+49 721 1001",
            presenceStatus: .available
        )
    }
}
