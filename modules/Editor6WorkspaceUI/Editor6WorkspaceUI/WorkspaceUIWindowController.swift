//
//  WorkspaceUIWindowController.swift
//  Editor6WorkspaceUI
//
//  Created by Hoon H. on 2016/11/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EonilToolbox
import Editor6Common

public final class WorkspaceUIWindowController: NSWindowController, NSWindowDelegate {
    private let workspaceViewController = WorkspaceUIViewController()
    private var installer = ViewInstaller()
    public var delegate: ((Event) -> ())?

    public typealias Event = WorkspaceUIAction

    @objc
    public convenience init() {
        self.init(window: nil)
    }
    @objc
    @available(*,unavailable)
    public required init?(coder: NSCoder) {
        fatalError("IB/SB are not supported.")
    }
    @objc
    internal override init(window: NSWindow?) {
        super.init(window: window)
        self.window = window
        self.loadWindow()
        self.windowDidLoad()
    }

    public func reload(_ newState: WorkspaceUIState) {
        assert(delegate != nil)
        workspaceViewController.reload(newState)
    }

    private func render() {
        installer.installIfNeeded {
            guard let window = window else { reportFatalError() }
//            window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            window.styleMask.formUnion([.resizable, .miniaturizable, .closable, .titled])
            window.contentViewController = workspaceViewController
            window.setContentSize(NSSize(width: 500, height: 500))
            window.delegate = self
        }
    }

    public override func loadWindow() {
        window = NSWindow()
    }
    public override func windowDidLoad() {
        super.windowDidLoad()
        render()
    }
    @available(*,unavailable)
    public func windowDidResize(_ notification: Notification) {
        render()
    }

    @available(*,unavailable)
    public func windowWillClose(_ notification: Notification) {
        delegate?(.close)
    }
}