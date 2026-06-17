//
//  PreferencesViewModel.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 17.06.26.
//

import Combine
import Foundation

final class PreferencesViewModel: ObservableObject {

    private enum Defaults {
        static let serverAddress = "https://pbx.starface.example"
        static let extensionNumber = "1001"
        static let startsAtLogin = false
        static let notificationsEnabled = true
        static let selectedAudioDevice = "MacBook Microphone"
    }

    private enum Keys {
        static let serverAddress = "preferences.serverAddress"
        static let extensionNumber = "preferences.extensionNumber"
        static let startsAtLogin = "preferences.startsAtLogin"
        static let notificationsEnabled = "preferences.notificationsEnabled"
        static let selectedAudioDevice = "preferences.selectedAudioDevice"
    }

    private let userDefaults: UserDefaults

    @Published var serverAddress: String {
        didSet {
            userDefaults.set(serverAddress, forKey: Keys.serverAddress)
        }
    }

    @Published var extensionNumber: String {
        didSet {
            userDefaults.set(extensionNumber, forKey: Keys.extensionNumber)
        }
    }

    @Published var startsAtLogin: Bool {
        didSet {
            userDefaults.set(startsAtLogin, forKey: Keys.startsAtLogin)
        }
    }

    @Published var notificationsEnabled: Bool {
        didSet {
            userDefaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    @Published var selectedAudioDevice: String {
        didSet {
            userDefaults.set(selectedAudioDevice, forKey: Keys.selectedAudioDevice)
        }
    }

    let audioDevices = [
        "MacBook Microphone",
        "USB Headset",
        "Bluetooth Speaker"
    ]

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        serverAddress = userDefaults.string(forKey: Keys.serverAddress)
            ?? Defaults.serverAddress
        extensionNumber = userDefaults.string(forKey: Keys.extensionNumber)
            ?? Defaults.extensionNumber
        startsAtLogin = userDefaults.object(forKey: Keys.startsAtLogin) as? Bool
            ?? Defaults.startsAtLogin
        notificationsEnabled = userDefaults.object(forKey: Keys.notificationsEnabled) as? Bool
            ?? Defaults.notificationsEnabled

        let storedAudioDevice = userDefaults.string(forKey: Keys.selectedAudioDevice)
            ?? Defaults.selectedAudioDevice
        selectedAudioDevice = audioDevices.contains(storedAudioDevice)
            ? storedAudioDevice
            : Defaults.selectedAudioDevice
    }

    func resetToDefaults() {
        serverAddress = Defaults.serverAddress
        extensionNumber = Defaults.extensionNumber
        startsAtLogin = Defaults.startsAtLogin
        notificationsEnabled = Defaults.notificationsEnabled
        selectedAudioDevice = Defaults.selectedAudioDevice
    }
}
