//
//  ViewModelTests.swift
//  StarfaceMacClientDemoTests
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Foundation
import Testing
@testable import StarfaceMacClientDemo

@MainActor
struct ContactsViewModelTests {

    @Test
    func refreshContactsPublishesFetchedContacts() async {
        let contacts = [
            makeContact(name: "Anna Keller", presenceStatus: .available),
            makeContact(name: "Markus Weber", presenceStatus: .busy)
        ]
        let viewModel = ContactsViewModel(
            contactService: ContactServiceMock(result: .success(contacts))
        )

        await viewModel.refreshContacts()

        #expect(viewModel.contacts == contacts)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.lastErrorMessage == nil)
    }

    @Test
    func refreshContactsPublishesErrorMessageOnFailure() async {
        let viewModel = ContactsViewModel(
            contactService: ContactServiceMock(result: .failure(TestError.failed))
        )

        await viewModel.refreshContacts()

        #expect(viewModel.contacts.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.lastErrorMessage == "Unable to load contacts.")
    }

    @Test
    func applyPresenceUpdateChangesMatchingContactOnly() async {
        let anna = makeContact(
            name: "Anna Keller",
            phoneNumber: "+49 721 1001",
            presenceStatus: .available
        )
        let markus = makeContact(
            name: "Markus Weber",
            phoneNumber: "+49 721 1002",
            presenceStatus: .busy
        )
        let viewModel = ContactsViewModel(
            contactService: ContactServiceMock(result: .success([anna, markus]))
        )

        await viewModel.refreshContacts()
        viewModel.applyPresenceUpdate(
            ContactPresenceUpdate(
                phoneNumber: "+49 721 1001",
                presenceStatus: .offline
            )
        )

        #expect(viewModel.contacts[0].presenceStatus == .offline)
        #expect(viewModel.contacts[1].presenceStatus == .busy)
    }
}

@MainActor
struct CallHistoryViewModelTests {

    @Test
    func refreshCallHistoryPublishesFetchedRecords() async {
        let records = [
            makeCallRecord(contactName: "Anna Keller", direction: .incoming),
            makeCallRecord(contactName: "Markus Weber", direction: .missed)
        ]
        let viewModel = CallHistoryViewModel(
            callHistoryService: CallHistoryServiceMock(result: .success(records))
        )

        await viewModel.refreshCallHistory()

        #expect(viewModel.records == records)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.lastErrorMessage == nil)
    }

    @Test
    func refreshCallHistoryPublishesErrorMessageOnFailure() async {
        let viewModel = CallHistoryViewModel(
            callHistoryService: CallHistoryServiceMock(result: .failure(TestError.failed))
        )

        await viewModel.refreshCallHistory()

        #expect(viewModel.records.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.lastErrorMessage == "Unable to load call history.")
    }

    @Test
    func insertCompletedCallAddsRecordAtTop() {
        let olderRecord = makeCallRecord(contactName: "Anna Keller", direction: .incoming)
        let completedRecord = makeCallRecord(contactName: "Julia Fischer", direction: .outgoing)
        let viewModel = CallHistoryViewModel(
            callHistoryService: CallHistoryServiceMock(result: .success([olderRecord]))
        )

        viewModel.insertCompletedCall(olderRecord)
        viewModel.insertCompletedCall(completedRecord)

        #expect(viewModel.records.first == completedRecord)
        #expect(viewModel.records.last == olderRecord)
    }
}

@MainActor
struct PreferencesViewModelTests {

    @Test
    func savesAndRestoresPreferences() {
        let (suiteName, userDefaults) = makeUserDefaultsSuite()
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let viewModel = PreferencesViewModel(userDefaults: userDefaults)
        viewModel.serverAddress = "https://pbx.demo.test"
        viewModel.extensionNumber = "2042"
        viewModel.startsAtLogin = true
        viewModel.notificationsEnabled = false
        viewModel.selectedAudioDevice = "USB Headset"

        let restoredViewModel = PreferencesViewModel(userDefaults: userDefaults)

        #expect(restoredViewModel.serverAddress == "https://pbx.demo.test")
        #expect(restoredViewModel.extensionNumber == "2042")
        #expect(restoredViewModel.startsAtLogin == true)
        #expect(restoredViewModel.notificationsEnabled == false)
        #expect(restoredViewModel.selectedAudioDevice == "USB Headset")
    }

    @Test
    func resetToDefaultsPersistsDefaultPreferences() {
        let (suiteName, userDefaults) = makeUserDefaultsSuite()
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let viewModel = PreferencesViewModel(userDefaults: userDefaults)
        viewModel.serverAddress = "https://pbx.demo.test"
        viewModel.extensionNumber = "2042"
        viewModel.startsAtLogin = true
        viewModel.notificationsEnabled = false
        viewModel.selectedAudioDevice = "USB Headset"

        viewModel.resetToDefaults()

        let restoredViewModel = PreferencesViewModel(userDefaults: userDefaults)

        #expect(restoredViewModel.serverAddress == "https://pbx.starface.example")
        #expect(restoredViewModel.extensionNumber == "1001")
        #expect(restoredViewModel.startsAtLogin == false)
        #expect(restoredViewModel.notificationsEnabled == true)
        #expect(restoredViewModel.selectedAudioDevice == "MacBook Microphone")
    }
}

private struct ContactServiceMock: ContactServicing {

    let result: Result<[Contact], Error>

    func fetchContacts() async throws -> [Contact] {
        try result.get()
    }
}

private struct CallHistoryServiceMock: CallHistoryServicing {

    let result: Result<[CallRecord], Error>

    func fetchCallHistory() async throws -> [CallRecord] {
        try result.get()
    }
}

private enum TestError: Error {
    case failed
}

private func makeUserDefaultsSuite() -> (String, UserDefaults) {
    let suiteName = "StarfaceMacClientDemoTests.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    userDefaults.removePersistentDomain(forName: suiteName)

    return (suiteName, userDefaults)
}

private func makeContact(
    name: String,
    phoneNumber: String = "+49 721 1001",
    presenceStatus: PresenceStatus
) -> Contact {
    Contact(
        name: name,
        department: "Sales",
        phoneNumber: phoneNumber,
        presenceStatus: presenceStatus
    )
}

private func makeCallRecord(
    contactName: String,
    direction: CallDirection
) -> CallRecord {
    CallRecord(
        contactName: contactName,
        phoneNumber: "+49 721 1001",
        direction: direction,
        timestamp: Date(timeIntervalSince1970: 1_780_000_000),
        duration: 120
    )
}
