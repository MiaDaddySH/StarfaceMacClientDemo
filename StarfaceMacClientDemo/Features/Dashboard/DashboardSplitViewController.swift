//
//  DashboardSplitViewController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

final class DashboardSplitViewController: NSViewController {

    private let contactsViewController = ContactsViewController()
    private let callPanelViewController = CallPanelViewController()
    private let splitView = NSSplitView()
    private var didSetInitialDividerPosition = false

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSplitView()
        bindViewControllers()
    }

    private func setupSplitView() {
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        splitView.delegate = self
        splitView.translatesAutoresizingMaskIntoConstraints = false

        addChild(contactsViewController)
        addChild(callPanelViewController)

        splitView.addArrangedSubview(contactsViewController.view)
        splitView.addArrangedSubview(callPanelViewController.view)

        view.addSubview(splitView)

        NSLayoutConstraint.activate([
            splitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splitView.topAnchor.constraint(equalTo: view.topAnchor),
            splitView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewControllers() {
        contactsViewController.onContactSelected = { [weak self] contact in
            self?.callPanelViewController.show(contact: contact)
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        guard !didSetInitialDividerPosition,
              splitView.arrangedSubviews.count == 2,
              view.bounds.width > 0
        else {
            return
        }

        splitView.setPosition(300, ofDividerAt: 0)
        didSetInitialDividerPosition = true
    }
}

extension DashboardSplitViewController: NSSplitViewDelegate {

    func splitView(
        _ splitView: NSSplitView,
        constrainMinCoordinate proposedMinimumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        260
    }

    func splitView(
        _ splitView: NSSplitView,
        constrainMaxCoordinate proposedMaximumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        min(proposedMaximumPosition, 340)
    }
}
