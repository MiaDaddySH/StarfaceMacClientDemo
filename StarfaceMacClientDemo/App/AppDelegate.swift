//
//  AppDelegate.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa
import Combine
import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {

    private let clientStatusStore = ClientStatusStore()

    private var mainWindow: NSWindow?
    private var preferencesWindow: NSWindow?
    private var statusBarController: StatusBarController?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        setupStatusBarController()
        showMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if mainWindow?.isVisible != true {
            showMainWindow()
        }
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        guard !flag else {
            return true
        }

        showMainWindow()

        return true
    }

    private func showMainWindow() {
        let window = mainWindow ?? makeMainWindow()

        mainWindow = window
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()

        NSApp.unhide(nil)
        NSRunningApplication.current.activate(options: [
            .activateAllWindows
        ])
    }

    private func setupStatusBarController() {
        let statusBarController = StatusBarController()

        statusBarController.onShowWindowRequested = { [weak self] in
            self?.showMainWindow()
        }

        statusBarController.onPreferencesRequested = { [weak self] in
            self?.showPreferencesWindow()
        }

        clientStatusStore.$status
            .sink { status in
                statusBarController.updateStatus(status)
            }
            .store(in: &cancellables)

        self.statusBarController = statusBarController
    }

    private func showPreferencesWindow() {
        let window = preferencesWindow ?? makePreferencesWindow()

        preferencesWindow = window
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()

        NSApp.unhide(nil)
        NSRunningApplication.current.activate(options: [
            .activateAllWindows
        ])
    }

    private func makeMainWindow() -> NSWindow {
        let dashboardViewController = NSHostingController(
            rootView: DashboardView(clientStatusStore: clientStatusStore)
        )

        let window = NSWindow(contentViewController: dashboardViewController)
        window.title = "STARFACE macOS Client Demo"
        window.setContentSize(NSSize(width: 960, height: 640))
        window.minSize = NSSize(width: 800, height: 520)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false

        return window
    }

    private func makePreferencesWindow() -> NSWindow {
        let preferencesViewController = NSHostingController(
            rootView: PreferencesView(viewModel: PreferencesViewModel())
        )

        let window = NSWindow(contentViewController: preferencesViewController)
        window.title = "Settings"
        window.setContentSize(NSSize(width: 520, height: 420))
        window.minSize = NSSize(width: 460, height: 360)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false

        return window
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
