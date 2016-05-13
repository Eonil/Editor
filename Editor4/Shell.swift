//
//  Shell.swift
//  Editor4
//
//  Created by Hoon H. on 2016/04/30.
//  Copyright © 2016 Eonil. All rights reserved.
//

import AppKit

/// Manages view-part.
///
/// Driver will call `render` method after finishing mutation of
/// state, and the state won't be changed until rendering finishes.
/// Even they dispatch some actions, the actions will be queued, 
/// and will not be applied immediately.
/// So, all view components are guaranteed to access same state in
/// a rendering session.
///
final class Shell: DriverAccessible {

    private let mainMenu: MainMenuController
    private let workspace: WorkspaceManager

    init() {
        NSAppearance.setCurrentAppearance(NSAppearance(named: NSAppearanceNameVibrantDark))
        mainMenu = MainMenuController()
        workspace = WorkspaceManager()
    }
    func render() {
//        Shell.broadcast()
        mainMenu.render()
        workspace.render()
        if let action = action {
            renderAction(action)
        }
    }
    private func renderAction(action: Action) {
        switch action {
        case .Shell(let action):
            renderAction(action)

        default:
            break
        }
    }
    private func renderAction(action: ShellAction) {
        switch action {
        case .Quit:
            NSApplication.sharedApplication().terminate(nil)

        default:
            MARK_unimplemented()
        }
    }

}





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// MARK: -
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//private typealias Cast = () -> ()
////private var observerTable = [(id: ObjectIdentifier, cast: Cast, deregisteredWhileBroadcasting: Bool)]()
//private var allObservers = [ObjectIdentifier: Cast]()
//private var allObserverDebuggingDescriptions = [ObjectIdentifier: String]()
//private var isBroadcasting = false
//private var registeredObserversWhileBroadcasting = [(id: ObjectIdentifier, cast: Cast, debugInfo: String)]()
//private var deregisteredObserversWhileBroadcasting = [ObjectIdentifier]()
//extension Shell {
//    /// Broadcasts rendering signal to all registered components.
//    ///
//    /// Why do we need this where we can call `render` method cascadely?
//    /// *Cascade* means nesting. Cascaded action routing can be broken at
//    /// anytime by missing routing link. This can happen easily because
//    /// program changes over time. And for each time it happens, we need
//    /// to search for them, and it's a huge cost. Flat is better than
//    /// nesting.
//    ///
//    /// So, `Shell` broadcasts actions to interested parties. I mean,
//    /// components. Each components must register themselves to shell to
//    /// get guaranteed action notification without concerning intermediate
//    /// routing links, so they can trigger rendering themselves.
//    ///
//    /// Actually this is mainly because of nested structure of AppKit
//    /// views. For UI architecture that keeps every views in flat space
//    /// wouldn't need this kind of trick.
//    ///
//    /// Thankfully, we employ immutable state tree sequence architecture,
//    /// the state is guaranteed not to be changed in broadcasting an action.
//    /// You can dispatch another action in broadcasting, and they will be
//    /// processed just like dispatched another actions --- asynchronously.
//    ///
//    /// ## Design Intensions
//    ///
//    /// This broadcasting facility is strictly only for UI part --- shell.
//    /// So, it's limited to be used in main thread only.
//    ///
//    private static func broadcast() {
//        assertMainThread()
//        isBroadcasting = true
//        for (id, cast) in allObservers {
//            guard deregisteredObserversWhileBroadcasting.contains(id) == false else { continue }
//            cast()
//        }
//        isBroadcasting = false
//        // Observers deregistered in broadcasting will not be called
//        // because they are already dead, so they cannot process anything.
//        while let last = deregisteredObserversWhileBroadcasting.tryRemoveLast() {
//            allObservers[last] = nil
//            allObserverDebuggingDescriptions[last] = nil
//        }
//        // Observers registered in broadcasting will not be called
//        // because it may
//        while let last = registeredObserversWhileBroadcasting.tryRemoveLast() {
//            allObservers[last.id] = last.cast
//            allObserverDebuggingDescriptions[last.id] = last.debugInfo
//        }
//    }
//    static func register<T: AnyObject where T: Renderable>(observer: T) {
//        assertMainThread()
//        register(observer, observer.dynamicType.render)
//    }
//    static func register<T: AnyObject>(observer: T, _ handler: T -> () -> ()) {
//        assertMainThread()
//        let id = ObjectIdentifier(observer)
//        let cast = { [weak observer] in
//            guard let observer = observer else {
//                let debugDescription = allObserverDebuggingDescriptions[id] ?? "????"
//                reportErrorToDevelopers("An observer has been dead without deregistering it from shell broadcasting. (\(debugDescription))")
//                return
//            }
//            handler(observer)()
//        }
//        let debugInfo = "\(observer)"
//
//        if isBroadcasting {
//            registeredObserversWhileBroadcasting.append((id, cast, debugInfo))
//        }
//        else {
//            allObserverDebuggingDescriptions[id] = "\(observer)"
//            allObservers[id] = cast
//        }
//    }
//    static func deregister<T: AnyObject>(observer: T) {
//        assertMainThread()
//        let id = ObjectIdentifier(observer)
//        if isBroadcasting {
//            deregisteredObserversWhileBroadcasting.append(id)
//        }
//        else {
//            allObservers[id] = nil
//            allObserverDebuggingDescriptions[id] = nil
//        }
//    }
//
//}










