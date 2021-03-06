//
//  WorkspaceModel.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import MulticastingStorage
import EditorCommon





/// A unit for a product.
/// A workspace can contain multiple projects.
///
/// You need to call `locate` to designate location of this
/// workspace. Workspace will be in an empty state until you
/// provide a location.
///
/// A workspace should work with an invalid path without crash.
/// A workspace can work even with `nil` locaiton. Anyway most
/// feature won't work with invalid paths.
///
public class WorkspaceModel: ModelSubnode<ApplicationModel>, BroadcastingModelType {





	///

	public let event	=	EventMulticast<Event>()

	///

	override func didJoinModelRoot() {
		super.didJoinModelRoot()

		assert(location != nil, "`location` must be set to a non-nil value before attaching workspace model node to model tree.")

		file.owner		=	self
		search.owner		=	self
		build.owner		=	self
		debug.owner		=	self
		report.owner		=	self
		console.owner		=	self
		cargo.owner		=	self

		_relocate()
		Event.DidInitiate.dualcastAsNotificationWithSender(self)
	}
	override func willLeaveModelRoot() {
		Event.WillTerminate.dualcastAsNotificationWithSender(self)

		cargo.owner		=	nil
		console.owner		=	nil
		report.owner		=	nil
		debug.owner		=	nil
		build.owner		=	nil
		search.owner		=	nil
		file.owner		=	nil

		super.willLeaveModelRoot()
	}

	///

	public var application: ApplicationModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}

	public let	file		=	FileTreeModel()
	public let	search		=	SearchModel()
	public let	build		=	BuildModel()
	public let	debug		=	DebuggingModel()
	public let	report		=	ReportingModel()
	public let	console		=	ConsoleModel()

        public let	textFileEditor	=	TextFileEditorModel()

	internal let	cargo		=	CargoModel()

	///

	/// A location for a project can be changed to provide smoother
	/// user experience.
	/// For instance, user can move workspace directory to another
	/// location, and we can just replace location without re-creating
	/// whole workspace UI.
	public var location: NSURL? {
		willSet {
		}
		didSet {
			if owner != nil {
				_relocate()
			}
		}
	}

	public private(set) var allProjects: [ProjectModel] = []
	public private(set) var currentProject: ProjectModel? 

	///

	/// Creates a new workspace file structure at current location
	/// if there's none. This method does not guarantee proper creation,
	/// and can fail for any reason.
	public func construct() throws {
		assert(location != nil)
		cargo.runNewAtURL(location!, asExecutable: true)
		cargo.waitForCompletion()
		file.tree	=	{
			let	t	=	WorkspaceItemTree()
			t.createRoot()
			let	n	=	WorkspaceItemNode(name: "Cargo.toml", isGroup: false)
			t.root!.subnodes.append(n)
			let	n1	=	WorkspaceItemNode(name: "src", isGroup: true)
			t.root!.subnodes.append(n1)
			let	n2	=	WorkspaceItemNode(name: "lib.rs", isGroup: false)
			n1.subnodes.append(n2)
			return	t
			}() as WorkspaceItemTree
		file.tree!.root
		file.storeSnapshot()
		_relocate()
	}

//	public func demolish() {
//	}

	public func insertProjectWithRootURL(url: NSURL) {
		assert(location != nil, "You cannot manage projects on a workspace with no location.")
		markUnimplemented()
//		let	p	=	ProjectModel()
//		p.owner		=	self
//		_projects
	}
	public func deleteProject(project: ProjectModel) {
		assert(location != nil, "You cannot manage projects on a workspace with no location.")
		markUnimplemented()
	}









	///

	private func _relocate() {
		Event.WillRelocate.dualcastAsNotificationWithSender(self)
		do {
			try file.restoreSnapshot()
		}
		catch {

		}
		Event.DidRelocate.dualcastAsNotificationWithSender(self)
	}



}


































