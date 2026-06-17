//
//  CallHistoryViewModel.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Combine
import Foundation

@MainActor
final class CallHistoryViewModel: ObservableObject {

    private let callHistoryService: CallHistoryServicing

    @Published private(set) var records: [CallRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastErrorMessage: String?

    init() {
        self.callHistoryService = CallHistoryService()
    }

    init(callHistoryService: CallHistoryServicing) {
        self.callHistoryService = callHistoryService
    }

    func loadCallHistory() {
        Task {
            await refreshCallHistory()
        }
    }

    func refreshCallHistory() async {
        isLoading = true
        lastErrorMessage = nil

        do {
            records = try await callHistoryService.fetchCallHistory()
        } catch {
            lastErrorMessage = "Unable to load call history."
        }

        isLoading = false
    }

    func insertCompletedCall(_ record: CallRecord) {
        records.insert(record, at: 0)
    }
}
