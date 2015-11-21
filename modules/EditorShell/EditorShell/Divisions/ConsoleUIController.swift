//
//  ConsoleUIController.swift
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

class ConsoleUIController: CommonViewController {

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
	private let	_textView	=	_instantiateReportTextView()




	///

	private func _install() {
		assert(model != nil)
		view.addSubview(_scrollV)
		_scrollV.documentView		=	_textView
		ConsoleModel.Event.Notification.register	(self, ConsoleUIController._process)
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
		case .DidAppendSpan(let span):
			switch span {
			case .BuildOutput(let s):
				let	s1	=	NSAttributedString(string: s, attributes: _outputTextAttributes(_textView.typingAttributes))
				_textView.textStorage!.appendAttributedString(s1)

			case .BuildError(let s):
				let	s1	=	NSAttributedString(string: s, attributes: _errorTextAttributes(_textView.typingAttributes))
				_textView.textStorage!.appendAttributedString(s1)

			case .ExecutionOutput(_):
				markUnimplemented()

			case .ExecutionError(_):
				markUnimplemented()
			}

		case .DidClear:
			_textView.textStorage!.deleteCharactersInRange(NSRange(location: 0, length: _textView.textStorage!.length))
		}
	}
}





private func _outputTextAttributes(typingAttributes: [String: AnyObject]) -> [String : AnyObject] {
	var	attrs	=	typingAttributes
	attrs[NSForegroundColorAttributeName]	=	NSColor.controlTextColor()
	return	attrs
}
private func _errorTextAttributes(typingAttributes: [String: AnyObject]) -> [String : AnyObject] {
	var	attrs	=	typingAttributes
	attrs[NSForegroundColorAttributeName]	=	NSColor.magentaColor()
	return	attrs
}






private func _instantiateReportTextView() -> NSTextView {
	let	v	=	CommonViewFactory.instantiateTextViewForCodeDisplay()
	v.font		=	CommonFont.codeFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize))
	return	v
}




