//
//  StatusBarController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

final class StatusBarController {

    var onShowWindowRequested: (() -> Void)?
    var onPreferencesRequested: (() -> Void)?

    private let statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        configureButton()
        updateStatus(.available)
    }

    func updateStatus(_ status: ClientStatus) {
        statusItem.button?.title = status.menuBarTitle
        statusItem.menu = makeMenu(status: status)
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            systemSymbolName: "phone.fill",
            accessibilityDescription: "STARFACE Demo"
        )
        button.imagePosition = .imageLeading
    }

    private func makeMenu(status: ClientStatus) -> NSMenu {
        let menu = NSMenu()

        let statusItem = NSMenuItem(
            title: "Status: \(status.displayTitle)",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "Show STARFACE Demo",
            action: #selector(showWindow),
            keyEquivalent: ""
        ).target = self

        menu.addItem(
            withTitle: "Settings...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        ).target = self

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "Quit",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        ).target = self

        return menu
    }

    @objc
    private func showWindow() {
        onShowWindowRequested?()
    }

    @objc
    private func showPreferences() {
        onPreferencesRequested?()
    }

    @objc
    private func quitApplication() {
        NSApp.terminate(nil)
    }
}

private extension ClientStatus {

    var menuBarTitle: String {
        " \(displayTitle)"
    }
}
