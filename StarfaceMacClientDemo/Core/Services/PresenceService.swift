//
//  PresenceService.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Foundation

struct ContactPresenceUpdate: Equatable {
    let phoneNumber: String
    let presenceStatus: PresenceStatus
}

protocol PresenceServicing {

    func presenceUpdates() -> AsyncStream<ContactPresenceUpdate>
}

final class PresenceService: PresenceServicing {

    func presenceUpdates() -> AsyncStream<ContactPresenceUpdate> {
        AsyncStream { continuation in
            let task = Task {
                let updates = [
                    ContactPresenceUpdate(
                        phoneNumber: "+49 721 1001",
                        presenceStatus: .busy
                    ),
                    ContactPresenceUpdate(
                        phoneNumber: "+49 721 1002",
                        presenceStatus: .available
                    ),
                    ContactPresenceUpdate(
                        phoneNumber: "+49 721 1003",
                        presenceStatus: .available
                    ),
                    ContactPresenceUpdate(
                        phoneNumber: "+49 721 1001",
                        presenceStatus: .available
                    ),
                    ContactPresenceUpdate(
                        phoneNumber: "+49 721 1002",
                        presenceStatus: .offline
                    )
                ]

                var updateIndex = 0

                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)

                    guard !Task.isCancelled else {
                        break
                    }

                    continuation.yield(updates[updateIndex % updates.count])
                    updateIndex += 1
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
