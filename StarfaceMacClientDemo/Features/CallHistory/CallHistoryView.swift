//
//  CallHistoryView.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import SwiftUI

struct CallHistoryView: View {

    @ObservedObject var viewModel: CallHistoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            viewModel.loadCallHistory()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.records.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let lastErrorMessage = viewModel.lastErrorMessage {
            Text(lastErrorMessage)
                .font(.callout)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.records.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.records) { record in
                        CallHistoryRowView(record: record)

                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
            .scrollIndicators(.visible)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Call History")
                    .font(.headline)

                Text("\(viewModel.records.count) recent calls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "phone.badge.clock")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)

            Text("No recent calls")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CallHistoryRowView: View {

    let record: CallRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.direction.symbolName)
                .foregroundStyle(record.direction.tintColor)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(record.contactName)
                    .font(.body)
                    .fontWeight(.medium)

                Text(record.phoneNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(record.timestamp.preciseTimeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(record.durationText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }
}

private extension CallRecord {

    var durationText: String {
        guard let duration else {
            return direction.rawValue
        }

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        return String(format: "%d:%02d", minutes, seconds)
    }
}

private extension Date {

    var preciseTimeText: String {
        Self.callHistoryTimeFormatter.string(from: self)
    }

    static let callHistoryTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

private extension CallDirection {

    var symbolName: String {
        switch self {
        case .incoming:
            return "phone.arrow.down.left"
        case .outgoing:
            return "phone.arrow.up.right"
        case .missed:
            return "phone.down"
        }
    }

    var tintColor: Color {
        switch self {
        case .incoming:
            return .green
        case .outgoing:
            return .blue
        case .missed:
            return .red
        }
    }
}
