//
//  ClientStatusStore.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Combine
import Foundation

enum ClientStatus: Equatable {
    case available
    case ringing
    case inCall
    case offline

    var displayTitle: String {
        switch self {
        case .available:
            return "Available"
        case .ringing:
            return "Ringing"
        case .inCall:
            return "In Call"
        case .offline:
            return "Offline"
        }
    }
}

@MainActor
final class ClientStatusStore: ObservableObject {

    @Published private(set) var status: ClientStatus = .available

    func update(from callState: CallState) {
        switch callState {
        case .idle, .ended:
            status = .available
        case .ringing:
            status = .ringing
        case .dialing, .connecting, .active, .held:
            status = .inCall
        }
    }
}
