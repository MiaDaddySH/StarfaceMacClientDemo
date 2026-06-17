//
//  ContactsViewController.swift
//  StarfaceMacClientDemo
//
//  Created by Yuangang Sheng on 16.06.26.
//

import Cocoa

final class ContactsViewController: NSViewController {

    var onContactSelected: ((Contact) -> Void)?

    private let viewModel = ContactsViewModel()

    private let tableView = NSTableView()
    private let scrollView = NSScrollView()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        viewModel.loadContacts()
        tableView.reloadData()
    }

    private func setupTableView() {

        let column = NSTableColumn(
            identifier: NSUserInterfaceItemIdentifier("ContactColumn")
        )

        column.title = "Contacts"
        column.width = 280

        tableView.addTableColumn(column)
        tableView.headerView = nil

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 54

        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ContactsViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        viewModel.numberOfContacts
    }
}

extension ContactsViewController: NSTableViewDelegate {

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {

        guard let contact = viewModel.contact(at: row) else {
            return nil
        }

        let cell = NSTableCellView()

        let textField = NSTextField(
            labelWithString:
                "\(contact.name)\n\(contact.department)"
        )

        textField.maximumNumberOfLines = 2
        textField.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: cell.leadingAnchor,
                constant: 12
            ),

            textField.centerYAnchor.constraint(
                equalTo: cell.centerYAnchor
            )
        ])

        return cell
    }

    func tableViewSelectionDidChange(
        _ notification: Notification
    ) {

        let selectedRow = tableView.selectedRow

        guard selectedRow >= 0,
              let contact = viewModel.contact(at: selectedRow)
        else {
            return
        }

        onContactSelected?(contact)
    }
}
