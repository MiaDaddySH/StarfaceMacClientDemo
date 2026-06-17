//
//  MainWindowController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

final class MainWindowController: NSWindowController {

    convenience init() {
        let dashboardViewController = DashboardSplitViewController()

        let window = NSWindow(contentViewController: dashboardViewController)
        window.title = "STARFACE macOS Client Demo"
        window.setContentSize(NSSize(width: 960, height: 640))
        window.minSize = NSSize(width: 800, height: 520)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.center()

        self.init(window: window)
    }
}
