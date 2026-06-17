//
//  CallPanelViewController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

final class CallPanelViewController: NSViewController {

    private let viewModel = CallPanelViewModel()

    private let nameLabel =
        NSTextField(labelWithString: "Select a Contact")

    private let stateLabel =
        NSTextField(labelWithString: "Idle")

    private let callButton =
        NSButton(title: "Call",
                 target: nil,
                 action: nil)

    private let endButton =
        NSButton(title: "Hang Up",
                 target: nil,
                 action: nil)

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    func show(contact: Contact) {

        viewModel.select(contact: contact)

        nameLabel.stringValue = contact.name

        updateUI()
    }

    private func setupUI() {

        nameLabel.font =
            .systemFont(ofSize: 28, weight: .semibold)

        stateLabel.font =
            .systemFont(ofSize: 16)

        callButton.target = self
        callButton.action = #selector(callTapped)

        endButton.target = self
        endButton.action = #selector(endTapped)

        let stackView = NSStackView(
            views: [
                nameLabel,
                stateLabel,
                callButton,
                endButton
            ]
        )

        stackView.orientation = .vertical
        stackView.spacing = 20

        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([

            stackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    @objc
    private func callTapped() {

        do {

            try viewModel.startCall()

            updateUI()

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1
            ) {

                try? self.viewModel.markConnecting()

                self.updateUI()
            }

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2
            ) {

                try? self.viewModel.markActive()

                self.updateUI()
            }

        } catch {

            print(error)
        }
    }

    @objc
    private func endTapped() {

        viewModel.endCall()

        updateUI()
    }

    private func updateUI() {

        switch viewModel.currentState {

        case .idle:
            stateLabel.stringValue = "Idle"

        case .dialing:
            stateLabel.stringValue = "Dialing..."

        case .connecting:
            stateLabel.stringValue = "Connecting..."

        case .active:
            stateLabel.stringValue = "Active Call"

        case .held:
            stateLabel.stringValue = "On Hold"

        case .ringing:
            stateLabel.stringValue = "Incoming Call"

        case .ended(let reason):
            stateLabel.stringValue =
                "Ended: \(reason.rawValue)"
        }
    }
}
