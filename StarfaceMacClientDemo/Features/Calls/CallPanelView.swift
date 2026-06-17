//
//  CallPanelView.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import SwiftUI

struct CallPanelView: View {

    @ObservedObject var viewModel: CallPanelViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            contactSummary
            callStateSummary
            actionButtons

            if let lastErrorMessage = viewModel.lastErrorMessage {
                Text(lastErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var contactSummary: some View {
        VStack(spacing: 8) {
            Text(viewModel.selectedContact?.name ?? "Select a Contact")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text(viewModel.selectedContact?.phoneNumber ?? "Choose a person from the contact list")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var callStateSummary: some View {
        VStack(spacing: 8) {
            Text(viewModel.currentState.displayTitle)
                .font(.title3)
                .fontWeight(.medium)

            Text(viewModel.currentState.detailText)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.startDemoCallFlow()
            } label: {
                Label("Call", systemImage: "phone.fill")
            }
            .keyboardShortcut(.return, modifiers: [])
            .disabled(!viewModel.canStartCall)

            Button {
                viewModel.endCall()
            } label: {
                Label("Hang Up", systemImage: "phone.down.fill")
            }
            .disabled(!viewModel.canEndCall)

            Button {
                viewModel.resetCall()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .disabled(!viewModel.currentState.isEnded)
        }
        .controlSize(.large)
    }
}

private extension CallState {

    var displayTitle: String {
        switch self {
        case .idle:
            return "Idle"
        case .ringing:
            return "Incoming Call"
        case .dialing:
            return "Dialing"
        case .connecting:
            return "Connecting"
        case .active:
            return "Active Call"
        case .held:
            return "On Hold"
        case .ended(let reason):
            return "Ended: \(reason.rawValue)"
        }
    }

    var detailText: String {
        switch self {
        case .idle:
            return "Ready to start a demo call."
        case .ringing(let contact):
            return "\(contact.name) is calling."
        case .dialing(let contact):
            return "Calling \(contact.name)..."
        case .connecting(let contact):
            return "Connecting to \(contact.name)..."
        case .active(let contact, _):
            return "You are connected with \(contact.name)."
        case .held(let contact):
            return "\(contact.name) is currently on hold."
        case .ended:
            return "The call has finished."
        }
    }

    var isEnded: Bool {
        if case .ended = self {
            return true
        }

        return false
    }
}
