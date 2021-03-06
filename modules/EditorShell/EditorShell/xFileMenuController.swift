////
////  FileMenuController.swift
////  EditorShell
////
////  Created by Hoon H. on 2015/08/20.
////  Copyright © 2015 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//import EditorCommon
//import EditorModel
//
//
//
//class FileMenuController: SessionProtocol {
//
//	weak var model: ApplicationModel?
//
//	///
//
//	init() {
//		menu	=
//			_topLevelMenu("File", items: [
//				_menuItem("New", submenu: new.menu),
//				_menuItem("Open", submenu: open.menu),
//				closeWorkspace,
//				])
//
//	}
//	deinit {
//	}
//
//	///
//
//	let	menu		:	TopLevelCommandMenu
//	let	new		=	FileNewMenuController()
//	let	open		=	FileOpenMenuController()
//	let	closeWorkspace	=	_menuItem("Close Workspace", shortcut: Command+"W")
//
//	func run() {
//		assert(model != nil)
//
//		closeWorkspace.clickHandler	=	{ [weak self] in
//			self?._handleClosingCurrentWorkspace()
//		}
//
//		_applyModelState()
//		ApplicationModel.Event.Notification.register	(self, FileMenuController._process)
//
//		new.model	=	model!
//		new.run()
//
//		open.model	=	model!
//		open.run()
//	}
//	func halt() {
//		assert(model != nil)
//
//		open.halt()
//		open.model	=	nil
//
//		new.halt()
//		new.model	=	nil
//
//		ApplicationModel.Event.Notification.deregister(self)
//
//		closeWorkspace.clickHandler	=	nil
//	}
//
//	private func _process(n: ApplicationModel.Event.Notification) {
//		_applyModelState()
//	}
//
//
//
//
//
//
//	///
//
//	private func _applyModelState() {
//		print("_applyEnabledStates")
//		assert(model != nil)
//		closeWorkspace.enabled		=	model!.currentWorkspace != nil
//	}
//	private func _handleClosingCurrentWorkspace() {
//		assert(model != nil)
//		assert(model!.currentWorkspace != nil)
//		if let curWS = model!.currentWorkspace {
//			assert(model!.workspaces.contains(curWS) == true)
////			model!.deselectCurrentWorkspace()
////			assert(model!.currentWorkspace.value !== curWS)
////			assert(model!.workspaces.contains(curWS) == true)
//			model!.closeWorkspace(curWS)
//			assert(model!.workspaces.contains(curWS) == false)
//		}
//		else {
//			fatalError()
//		}
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//class FileNewMenuController: SessionProtocol {
//	weak var model: ApplicationModel?
//
//	let	menu		:	NSMenu
//	let	workspace	=	_menuItem("Workspace...", shortcut: Command+Control+"N")
//	let	file		=	_menuItem("File", shortcut: Command+"N")
//	let	folder		=	_menuItem("Folder", shortcut: Command+Alternate+"N")
//
//	init() {
//		menu		=	_menu("New...", items: [
//			workspace,
//			file,
//			folder,
//			])
//	}
//	func run() {
//		_applyModelState()
//		workspace.clickHandler	=	{ [weak self] in self!._clickWorkspace() }
//		file.clickHandler	=	{ [weak self] in self!._clickFile() }
//		folder.clickHandler	=	{ [weak self] in self!._clickFolder() }
//		ApplicationModel.Event.Notification.register		(self, FileNewMenuController._process)
//	}
//	func halt() {
//		ApplicationModel.Event.Notification.deregister		(self)
//		folder.clickHandler	=	nil
//		file.clickHandler	=	nil
//		workspace.clickHandler	=	nil
//	}
//
//	///
//
//	private func _process(n: ApplicationModel.Event.Notification) {
//		_applyModelState()
//	}
//
//
//
//
//
//
//	///
//
//	private func _applyModelState() {
//		let	hasSelectedFile	=	model!.currentWorkspace != nil && model!.currentWorkspace!.location != nil // && model!.defaultWorkspace.value!.file.selection.
//		workspace.enabled	=	true
//		file.enabled		=	hasSelectedFile
//		folder.enabled		=	hasSelectedFile
//	}
//
//	private func _clickWorkspace() {
//		Dialogue.runSavingWorkspace({ [weak self] (u: NSURL?) -> () in
//			if let u = u {
//				try! self?.model!.createAndOpenWorkspaceAtURL(u)
//			}
//		})
//	}
//	private func _clickFile() {
//		checkAndReportFailureToDevelopers(model!.currentWorkspace != nil)
//
//		// TODO:
//		// 1. Select location by asking user with file open panel.
//		//    We cannot depend on file-tree UI's selection state.
//		// 2. Try to create one at there.
//		_testCreatingFile1()
//	}
//	private func _clickFolder() {
//		checkAndReportFailureToDevelopers(model!.currentWorkspace != nil)
//
//		// TODO:
//		// 1. Select location by asking user with file open panel.
//		//    We cannot depend on file-tree UI's selection state.
//		// 2. Try to create one at there.
//		_testCreatingFolder1()
//	}
//
//	///
//
//	private func _testCreatingFile1() {
//		guard let ws = model!.currentWorkspace else {
//			fatalError("This shouldn't be called if current workspace is `nil`.")
//		}
//
//		do {
//			let	n	=	FileNodeModel(name: "qqQq", isGroup: false)
//			try ws.file.searchNodeAtPath(WorkspaceItemPath(parts: ["src"]))!.subnodes.append(n)
//		}
//		catch let error {
//			Dialogue.runErrorAlertModally(error)
//		}
//
////		if let ws = model!.defaultWorkspace.value {
////			let	p	=	WorkspaceItemPath(parts: ["ttt1"])
////			if ws.file.containsNodeAtPath(p) == false {
////				do {
////					let	newFolderNode	=	FileNodeModel(name: "GGG", isGroup: true)
////					try ws.file.searchNodeAtPath(p)?.subnodes.append(newFolderNode)
////				}
////				catch let error {
////					Dialogue.runErrorAlertModally(error)
////				}
////			}
////
////			struct Local {
////				static var	once	=	false
////			}
////			if Local.once {
////				let	p1	=	WorkspaceItemPath(parts: ["ttt1", "ttt2"])
////				if ws.file.containsNodeAtPath(p1) == false {
////					do {
////						ws.file.searchNodeAtPath(p1)
////						try ws.file.createFileAtPath(p1)
////					}
////					catch let error {
////						Dialogue.runErrorAlertModally(error)
////					}
////				}
////			}
////			else {
////				let	p1	=	WorkspaceItemPath(parts: ["ttt1", "ttt3"])
////				if ws.file.containsNodeAtPath(p1) == false {
////					do {
////						try ws.file.createFileAtPath(p1)
////					}
////					catch let error {
////						Dialogue.runErrorAlertModally(error)
////					}
////				}
////			}
////
////			Local.once	=	true
////		}
//	}
//
//	private func _testCreatingFolder1() {
//		if let ws = model!.currentWorkspace {
//			do {
//				let	n	=	FileNodeModel(name: "yyY", isGroup: true)
//				try ws.file.searchNodeAtPath(WorkspaceItemPath(parts: ["src"]))!.subnodes.append(n)
////				try ws.file.createFolderAtPath(WorkspaceItemPath(parts: ["src", "t1"]))
////				try ws.file.createFolderAtPath(WorkspaceItemPath(parts: ["z1", "y2"]))
//			}
//			catch let error {
//				Dialogue.runErrorAlertModally(error)
//			}
//		}
//	}
//}
//class FileOpenMenuController: SessionProtocol {
//	weak var model: ApplicationModel?
//
//	let	menu		=	_menu("Open...", items: [])
//	let	workspace	=	_menuItem("Workspace...", shortcut: Command+"O")
//	let	clearRecent	=	_menuItem("Clear Recent Workspaces")
//
//	init() {
//
//	}
//	func run() {
//		assert(model != nil)
//
//		workspace.clickHandler	=	{ [weak self] in
//			Dialogue.runOpeningWorkspace({ (u: NSURL?) -> () in
//				if let u = u {
//					self?.model!.openWorkspaceAtURL(u)
//				}
//			})
//		}
//		clearRecent.clickHandler	=	{ [weak self] in
//			NSDocumentController.sharedDocumentController().clearRecentDocuments(self)
//		}
//
//		_menuAgent.owner	=	self
//		menu.delegate		=	_menuAgent
//	}
//	func halt() {
//		menu.delegate		=	nil
//		_menuAgent.owner	=	nil
//
//		clearRecent.clickHandler	=	nil
//		workspace.clickHandler	=	nil
//	}
//
//	///
//
//	private let	_menuAgent	=	_FileOpenMenuAgent()
//
//	private func _refillRecentMenuItems() {
//		func _makeRecentMenuItem(u: NSURL) -> NSMenuItem {
//			let	m	=	_menuItem(u.lastPathComponent!)
//			m.clickHandler	=	{ [weak self] in
//				self?.model!.openWorkspaceAtURL(u)
//			}
//			return	m
//		}
//		let	ms	=	NSDocumentController.sharedDocumentController().recentDocumentURLs.map(_makeRecentMenuItem)
//		menu.removeAllItems()
//		menu.addItem(workspace)
//		menu.addItem(_menuSeparatorItem())
//		for m in ms {
//			menu.addItem(m)
//		}
//		menu.addItem(_menuSeparatorItem())
//		menu.addItem(clearRecent)
//	}
//}
//
//@objc
//private final class _FileOpenMenuAgent: NSObject, NSMenuDelegate {
//	weak var owner: FileOpenMenuController?
//	@objc
//	private func menuWillOpen(menu: NSMenu) {
//		owner!._refillRecentMenuItems()
//	}
//}
//
//
//
//
//
//
//
