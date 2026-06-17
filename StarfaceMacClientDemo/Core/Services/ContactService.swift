//
//  ContactService.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

protocol ContactServicing {

    func fetchContacts() async throws -> [Contact]
}

final class ContactService: ContactServicing {

    func fetchContacts() async throws -> [Contact] {
        try await Task.sleep(nanoseconds: 250_000_000)

        return loadContacts()
    }

    func loadContacts() -> [Contact] {
        [
            Contact(
                name: "Anna Keller",
                department: "Sales",
                phoneNumber: "+49 721 1001",
                presenceStatus: .available
            ),
            Contact(
                name: "Markus Weber",
                department: "Support",
                phoneNumber: "+49 721 1002",
                presenceStatus: .busy
            ),
            Contact(
                name: "Julia Fischer",
                department: "Product Management",
                phoneNumber: "+49 721 1003",
                presenceStatus: .offline
            )
        ]
    }
}
