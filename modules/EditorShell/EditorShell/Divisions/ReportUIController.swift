//
//  ReportUIController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import MulticastingStorage
import EditorCommon
import EditorModel
import EditorUICommon

class ReportingUIController: CommonViewController {

	weak var model: WorkspaceModel?

	///

	override func installSubcomponents() {
		super.installSubcomponents()
		_install()
		_layout()
	}
	override func deinstallSubcomponents() {
		_deinstall()
		super.deinstallSubcomponents()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		_layout()
	}








	
	///

	private let	_scrollV	=	CommonViewFactory.instantiateScrollViewForCodeDisplayTextView()
	private let	_textView	=	CommonViewFactory.instantiateTextViewForCodeDisplay()




	///

	private func _install() {
		assert(model != nil)
		view.addSubview(_scrollV)
		_scrollV.documentView		=	_textView
		ConsoleModel.Event.Notification.register	(self, ReportingUIController._process)
	}
	private func _deinstall() {
		assert(model != nil)
		ConsoleModel.Event.Notification.deregister	(self)
		_scrollV.documentView		=	nil
		_scrollV.removeFromSuperview()
	}
	private func _layout() {
		assert(model != nil)
		_scrollV.frame			=	view.bounds
	}

	///

	private func _process(n: ConsoleModel.Event.Notification) {
		guard n.sender.workspace === model! else {
			return
		}
		switch n.event {
		case .DidAppendLine:
			let	line	=	n.sender.outputLines.last!
			let	s1	=	NSAttributedString(string: line, attributes: _textView.typingAttributes)
			_textView.textStorage!.appendAttributedString(s1)

		case .DidClear:
			_textView.string	=	nil
		}
	}
}




















