//
//  CallHistoryService.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Foundation

protocol CallHistoryServicing {

    func fetchCallHistory() async throws -> [CallRecord]
}

final class CallHistoryService: CallHistoryServicing {

    func fetchCallHistory() async throws -> [CallRecord] {
        try await Task.sleep(nanoseconds: 250_000_000)

        return loadCallHistory()
    }

    func loadCallHistory() -> [CallRecord] {
        [
            CallRecord(
                contactName: "Anna Keller",
                phoneNumber: "+49 721 1001",
                direction: .incoming,
                timestamp: Date().addingTimeInterval(-3600),
                duration: 180
            ),
            CallRecord(
                contactName: "Markus Weber",
                phoneNumber: "+49 721 1002",
                direction: .missed,
                timestamp: Date().addingTimeInterval(-7200),
                duration: nil
            )
        ]
    }
}
