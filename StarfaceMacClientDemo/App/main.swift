//
//  main.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

@MainActor
private let appDelegate = AppDelegate()

MainActor.assumeIsolated {
    let application = NSApplication.shared

    application.delegate = appDelegate
    application.setActivationPolicy(.regular)
    application.finishLaunching()
    application.run()
}
