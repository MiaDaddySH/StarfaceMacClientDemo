//
//  ContactsViewModel.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Combine
import Foundation

@MainActor
final class ContactsViewModel: ObservableObject {

    private let contactService: ContactServicing
    private let presenceService: PresenceServicing
    private var presenceUpdatesTask: Task<Void, Never>?

    @Published private(set) var contacts: [Contact] = []
    @Published var searchText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isReceivingPresenceUpdates = false
    @Published private(set) var lastErrorMessage: String?

    init() {
        self.contactService = ContactService()
        self.presenceService = PresenceService()
    }

    init(contactService: ContactServicing) {
        self.contactService = contactService
        self.presenceService = PresenceService()
    }

    init(
        contactService: ContactServicing,
        presenceService: PresenceServicing
    ) {
        self.contactService = contactService
        self.presenceService = presenceService
    }

    deinit {
        presenceUpdatesTask?.cancel()
    }

    func loadContacts() {
        Task {
            await refreshContacts()
        }
    }

    func refreshContacts() async {
        isLoading = true
        lastErrorMessage = nil

        do {
            contacts = try await contactService.fetchContacts()
        } catch {
            lastErrorMessage = "Unable to load contacts."
        }

        isLoading = false
    }

    func startPresenceUpdates() {
        guard presenceUpdatesTask == nil else {
            return
        }

        isReceivingPresenceUpdates = true

        presenceUpdatesTask = Task { [weak self] in
            guard let self else {
                return
            }

            for await update in presenceService.presenceUpdates() {
                applyPresenceUpdate(update)
            }
        }
    }

    func stopPresenceUpdates() {
        presenceUpdatesTask?.cancel()
        presenceUpdatesTask = nil
        isReceivingPresenceUpdates = false
    }

    func applyPresenceUpdate(_ update: ContactPresenceUpdate) {
        contacts = contacts.map { contact in
            guard contact.phoneNumber == update.phoneNumber else {
                return contact
            }

            return contact.updating(presenceStatus: update.presenceStatus)
        }
    }

    func contact(at index: Int) -> Contact? {
        guard contacts.indices.contains(index) else {
            return nil
        }

        return contacts[index]
    }

    var numberOfContacts: Int {
        contacts.count
    }

    var filteredContacts: [Contact] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else {
            return contacts
        }

        return contacts.filter { contact in
            contact.matches(searchText: trimmedSearchText)
        }
    }
}

private extension Contact {

    func matches(searchText: String) -> Bool {
        let searchableValues = [
            name,
            department,
            phoneNumber,
            presenceStatus.rawValue
        ]

        return searchableValues.contains { value in
            value.localizedCaseInsensitiveContains(searchText)
        }
    }
}
