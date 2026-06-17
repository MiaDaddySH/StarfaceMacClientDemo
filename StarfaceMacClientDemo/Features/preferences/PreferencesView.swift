//
//  PreferencesView.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import SwiftUI

struct PreferencesView: View {

    @ObservedObject var viewModel: PreferencesViewModel

    var body: some View {
        Form {
            Section("Account") {
                TextField("Server address", text: $viewModel.serverAddress)
                    .textFieldStyle(.roundedBorder)

                TextField("Extension", text: $viewModel.extensionNumber)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Desktop Integration") {
                Toggle("Start STARFACE Demo at login", isOn: $viewModel.startsAtLogin)
                Toggle("Show call notifications", isOn: $viewModel.notificationsEnabled)
            }

            Section("Audio") {
                Picker("Input device", selection: $viewModel.selectedAudioDevice) {
                    ForEach(viewModel.audioDevices, id: \.self) { device in
                        Text(device)
                    }
                }
            }

            Section {
                Button("Reset Defaults") {
                    viewModel.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520, height: 420)
        .tint(StarfaceColors.orange)
    }
}
