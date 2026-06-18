//
//  MainMenuController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 18.06.26.
//

import Cocoa

final class MainMenuController {

    var onShowWindowRequested: (() -> Void)?
    var onPreferencesRequested: (() -> Void)?

    func install() {
        let mainMenu = NSMenu()

        mainMenu.addItem(makeApplicationMenuItem())
        mainMenu.addItem(makeDemoMenuItem())
        mainMenu.addItem(makeWindowMenuItem())

        NSApp.mainMenu = mainMenu
    }

    private func makeApplicationMenuItem() -> NSMenuItem {
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()

        appMenu.addItem(
            withTitle: "About STARFACE Demo",
            action: #selector(showAboutPanel),
            keyEquivalent: ""
        ).target = self

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "Settings...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        ).target = self

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "Hide STARFACE Demo",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )

        let hideOthersItem = appMenu.addItem(
            withTitle: "Hide Others",
            action: #selector(NSApplication.hideOtherApplications(_:)),
            keyEquivalent: "h"
        )
        hideOthersItem.keyEquivalentModifierMask = [.command, .option]

        appMenu.addItem(
            withTitle: "Show All",
            action: #selector(NSApplication.unhideAllApplications(_:)),
            keyEquivalent: ""
        )

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "Quit STARFACE Demo",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        appMenuItem.submenu = appMenu
        return appMenuItem
    }

    private func makeDemoMenuItem() -> NSMenuItem {
        let demoMenuItem = NSMenuItem()
        let demoMenu = NSMenu(title: "Demo")

        demoMenu.addItem(
            withTitle: "Show Main Window",
            action: #selector(showWindow),
            keyEquivalent: "1"
        ).target = self

        demoMenu.addItem(
            withTitle: "Open Settings",
            action: #selector(showPreferences),
            keyEquivalent: ","
        ).target = self

        demoMenuItem.title = "Demo"
        demoMenuItem.submenu = demoMenu
        return demoMenuItem
    }

    private func makeWindowMenuItem() -> NSMenuItem {
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")

        windowMenu.addItem(
            withTitle: "Minimize",
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )

        windowMenu.addItem(
            withTitle: "Zoom",
            action: #selector(NSWindow.performZoom(_:)),
            keyEquivalent: ""
        )

        windowMenu.addItem(.separator())

        windowMenu.addItem(
            withTitle: "Bring All to Front",
            action: #selector(NSApplication.arrangeInFront(_:)),
            keyEquivalent: ""
        )

        windowMenuItem.title = "Window"
        windowMenuItem.submenu = windowMenu
        NSApp.windowsMenu = windowMenu

        return windowMenuItem
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
    private func showAboutPanel() {
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "STARFACE macOS Client Demo",
            .applicationVersion: "Interview Demo",
            .credits: NSAttributedString(
                string: "SwiftUI dashboard with AppKit window, menu bar, and notification integration."
            )
        ])
    }
}
