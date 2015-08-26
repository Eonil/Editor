//
//  ProductMenuController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/15.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import MulticastingStorage
import EditorCommon
import EditorUICommon
import EditorModel

class ProductMenuController: SessionProtocol {

	weak var model: ApplicationModel?

	///

	init() {
		menu	=	_topLevelMenu("Product", items: [
			launch,
			build,
			clean,
			stop,
			])
	}

	///

	let	menu		:	TopLevelCommandMenu
	let	launch		=	_menuItem("Run", shortcut: Command+"R")
	let	build		=	_menuItem("Build", shortcut: Command+"B")
	let	clean		=	_menuItem("Clean", shortcut: Command+"K")
	let	stop		=	_menuItem("Stop", shortcut: Command+".")

	func run() {
		assert(model != nil)
		_applyEnabledStates()

		_didSetDefaultWorkspace()
		model!.currentWorkspace.registerWillSet(ObjectIdentifier(self)) { [weak self] in
			assert(self != nil)
			self!._didSetDefaultWorkspace()
		}
		model!.currentWorkspace.registerDidSet(ObjectIdentifier(self)) { [weak self] in
			assert(self != nil)
			self!._didSetDefaultWorkspace()
		}

		launch.clickHandler	=	{ [weak self] in self?._runLaunchOnCurrentWorkspace() }
		build.clickHandler	=	{ [weak self] in self?._runBuildOnCurrentWorkspace() }
		clean.clickHandler	=	{ [weak self] in self?._runCleanOnCurrentWorkspace() }
		stop.clickHandler	=	{ [weak self] in self?._stopAnyOnCurrentWorkspace() }

	}
	func halt() {
		assert(model != nil)

		stop.clickHandler	=	nil
		clean.clickHandler	=	nil
		build.clickHandler	=	nil

		model!.currentWorkspace.deregisterDidSet(ObjectIdentifier(self))
		model!.currentWorkspace.deregisterWillSet(ObjectIdentifier(self))
		_willSetDefaultWorkspace()
	}

	///

	private func _install() {
	}
	private func _deinstall() {
	}
	private func _didSetDefaultWorkspace() {
		assert(model != nil)
		if let ws = model!.currentWorkspace.value {
			_applyEnabledStates()
			ws.build.runnableCommands.registerDidSet(ObjectIdentifier(self)) { [weak self] in
				assert(self != nil)
				self!._handleCurrentWorkspaceBuildCommandsDidSet()
			}
			ws.build.runnableCommands.registerWillSet(ObjectIdentifier(self)) { [weak self] in
				assert(self != nil)
			}
			ws.debug.currentTarget.registerDidSet(ObjectIdentifier(self)) { [weak self] in
				if let target = self!.model!.currentWorkspace.value!.debug.currentTarget.value {
					self!._didSetExecution()
					target.execution.registerDidSet(ObjectIdentifier(self!)) { [weak self] in
						self!._didSetExecution()
					}
					target.execution.registerWillSet(ObjectIdentifier(self!)) { [weak self] in
						self!._willSetExecution()
					}
					self!._willSetExecution()
				}
			}
			ws.debug.currentTarget.registerWillSet(ObjectIdentifier(self)) { [weak self] in
				if let target = self!.model!.currentWorkspace.value!.debug.currentTarget.value {
					target.execution.deregisterWillSet(ObjectIdentifier(self!))
					target.execution.deregisterDidSet(ObjectIdentifier(self!))
				}
			}
		}
		else {

		}
	}
	private func _willSetDefaultWorkspace() {
		if let ws = model!.currentWorkspace.value {
			ws.build.runnableCommands.deregisterWillSet(ObjectIdentifier(self))
			ws.build.runnableCommands.deregisterDidSet(ObjectIdentifier(self))
			_applyEnabledStates()
		}
	}

	private func _didSetDefaultTarget(t: DebuggingTargetModel?) {
		_applyEnabledStates()
	}
	private func _willSetDefaultTarget(t: DebuggingTargetModel?) {
	}
	private func _didSetExecution() {
		if let execution = model!.currentWorkspace.value!.debug.currentTarget.value!.execution.value {
			_didSetExecutionState()
			execution.state.registerDidSet(ObjectIdentifier(self)) { [weak self] in
				self!._didSetExecutionState()
			}
			execution.state.registerWillSet(ObjectIdentifier(self)) { [weak self] in
				self!._willSetExecutionState()
			}
		}
		_applyEnabledStates()
	}
	private func _willSetExecution() {
		if let execution = model!.currentWorkspace.value!.debug.currentTarget.value!.execution.value {
			execution.state.deregisterDidSet(ObjectIdentifier(self))
			execution.state.deregisterWillSet(ObjectIdentifier(self))
			_willSetExecutionState()
		}
		_applyEnabledStates()
	}
	private func _didSetExecutionState() {
		_applyEnabledStates()
	}
	private func _willSetExecutionState() {
		_applyEnabledStates()
	}

	private func _handleCurrentWorkspaceBuildCommandsDidSet() {
		_applyEnabledStates()
	}
	private func _applyEnabledStates() {
		assert(model != nil)
		let	cmds	=	model!.currentWorkspace.value?.build.runnableCommands.value ?? []
		let	running	=	model!.currentWorkspace.value?.debug.currentTarget.value?.execution.value != nil
		launch.enabled	=	true
		build.enabled	=	cmds.contains(.Build)
		clean.enabled	=	cmds.contains(.Clean)
		stop.enabled	=	cmds.contains(.Stop) || running
	}

	///

	private func _runLaunchOnCurrentWorkspace() {
		assert(model!.currentWorkspace.value != nil)
		if let ws = model!.currentWorkspace.value {
			if ws.debug.currentTarget.value == nil {
				if ws.debug.targets.array.count == 0 {
					markUnimplemented("We need to query `Cargo.toml` file to get proper executable location.")
					if let u = ws.location.value {
						let	n	=	u.lastPathComponent!
						let	u1	=	u.URLByAppendingPathComponent("target").URLByAppendingPathComponent("debug").URLByAppendingPathComponent(n)
						ws.debug.createTargetForExecutableAtURL(u1)
					}
				}
				ws.debug.selectTarget(ws.debug.targets.array.first!)
			}
			ws.debug.currentTarget.value!.launch(NSURL(fileURLWithPath: "."))
		}
	}
	private func _runBuildOnCurrentWorkspace() {
		assert(model!.currentWorkspace.value != nil)
		if let ws = model!.currentWorkspace.value {
			ws.build.runBuild()
		}
	}
	private func _runCleanOnCurrentWorkspace() {
		assert(model!.currentWorkspace.value != nil)
		if let ws = model!.currentWorkspace.value {
			ws.build.runClean()
		}
	}
	private func _stopAnyOnCurrentWorkspace() {
		assert(model!.currentWorkspace.value != nil)
		if let ws = model!.currentWorkspace.value {
			ws.build.stop()
			ws.debug.currentTarget.value?.halt()
		}
	}
}





private final class _Agent: ValueStorageDelegate {
	weak var owner: ProductMenuController?
	private func didSet() {

	}
	private func willSet() {

	}
}













