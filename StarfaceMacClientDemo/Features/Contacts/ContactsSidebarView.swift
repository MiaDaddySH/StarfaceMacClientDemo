//
//  ContactsSidebarView.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import SwiftUI

struct ContactsSidebarView: View {

    @ObservedObject var viewModel: ContactsViewModel

    let selectedContact: Contact?
    let onSelectContact: (Contact) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            content
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.contacts.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let lastErrorMessage = viewModel.lastErrorMessage {
            Text(lastErrorMessage)
                .font(.callout)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredContacts) { contact in
                        Button {
                            onSelectContact(contact)
                        } label: {
                            ContactRowView(
                                contact: contact,
                                isSelected: contact == selectedContact
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.leading, 68)
                            .opacity(contact == selectedContact ? 0 : 1)
                    }
                }
            }
            .scrollIndicators(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Contacts")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                if viewModel.isReceivingPresenceUpdates {
                    Label("Live presence", systemImage: "dot.radiowaves.left.and.right")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            TextField("Search contacts", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text(contactCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var contactCountText: String {
        if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(viewModel.contacts.count) people"
        }

        return "\(viewModel.filteredContacts.count) matches"
    }
}

private struct ContactRowView: View {

    let contact: Contact
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 3) {
                Text(contact.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(contact.department)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(contact.phoneNumber)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(contact.presenceStatus.rawValue)
                .font(.caption2)
                .foregroundStyle(contact.presenceStatus.statusColor)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(contact.presenceStatus.statusColor.opacity(0.12))
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.16) : .clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isSelected ? Color.accentColor.opacity(0.35) : .clear,
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.78),
                            Color(nsColor: .systemTeal).opacity(0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38, height: 38)
                .overlay(
                    Text(contact.initials)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                )

            Circle()
                .fill(contact.presenceStatus.statusColor)
                .frame(width: 11, height: 11)
                .overlay(
                    Circle()
                        .stroke(Color(nsColor: .controlBackgroundColor), lineWidth: 2)
                )
        }
    }
}

private extension Contact {

    var initials: String {
        name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
}

private extension PresenceStatus {

    var statusColor: Color {
        switch self {
        case .available:
            return .green
        case .busy:
            return .orange
        case .offline:
            return .gray
        }
    }
}
