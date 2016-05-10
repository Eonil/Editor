//
//  AppDelegate.swift
//  Editor4
//
//  Created by Hoon H. on 2016/04/19.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class ApplicationController: NSObject, NSApplicationDelegate, DriverAccessible {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // This is required and very important action dispatch.
        // Otherwise, driver will not be activated.
        dispatch(Action.Reset)
        let id = WorkspaceID()
        let u = NSURL(string: "~/Temp/ws1")!
        dispatch(Action.Workspace(id: id, command: WorkspaceAction.Open))
        dispatch(Action.Workspace(id: id, command: WorkspaceAction.Reconfigure(location: u)))
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
        return false
    }
}

