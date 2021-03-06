//
//  FileTreeUIController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/29.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EditorModel
import EditorUICommon
import EditorFileUI

class FileTreeUIController: CommonViewController {

	weak var model: FileTreeModel? {
		get {
			return	_view.model
		}
		set {
			_view.model	=	newValue
		}
	}

	///

	override func installSubcomponents() {
		super.installSubcomponents()
		_install()
	}
	override func deinstallSubcomponents() {
		_deinstall()
		super.deinstallSubcomponents()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		_layout()
	}




	override var acceptsFirstResponder: Bool {
		get {
			return	_view.acceptsFirstResponder
		}
	}
	override func becomeFirstResponder() -> Bool {
		return	view.window!.makeFirstResponder(_view)
	}














	///

	private let	_view	=	FileTreeUI()
	
	private func _install() {
		view.addSubview(_view)
	}
	private func _deinstall() {
		_view.removeFromSuperview()
	}
	private func _layout() {
		_view.frame	=	view.bounds
	}
}




