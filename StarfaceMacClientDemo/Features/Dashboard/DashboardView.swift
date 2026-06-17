//
//  DashboardView.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import SwiftUI

struct DashboardView: View {

    let clientStatusStore: ClientStatusStore

    @StateObject private var contactsViewModel = ContactsViewModel()
    @StateObject private var callPanelViewModel = CallPanelViewModel()
    @StateObject private var callHistoryViewModel = CallHistoryViewModel()

    var body: some View {
        HSplitView {
            ContactsSidebarView(
                viewModel: contactsViewModel,
                selectedContact: callPanelViewModel.selectedContact,
                onSelectContact: { contact in
                    callPanelViewModel.select(contact: contact)
                }
            )
            .frame(minWidth: 260, idealWidth: 300, maxWidth: 340)

            VSplitView {
                CallPanelView(viewModel: callPanelViewModel)
                    .frame(minHeight: 320)

                CallHistoryView(viewModel: callHistoryViewModel)
                    .frame(minHeight: 180, idealHeight: 220)
            }
                .frame(minWidth: 500)
        }
        .frame(minWidth: 800, minHeight: 520)
        .tint(StarfaceColors.orange)
        .onAppear {
            callPanelViewModel.onCallCompleted = { record in
                callHistoryViewModel.insertCompletedCall(record)
            }

            contactsViewModel.loadContacts()
            contactsViewModel.startPresenceUpdates()
        }
        .onDisappear {
            contactsViewModel.stopPresenceUpdates()
        }
        .onChange(of: callPanelViewModel.currentState) { _, newState in
            clientStatusStore.update(from: newState)
        }
    }
}
