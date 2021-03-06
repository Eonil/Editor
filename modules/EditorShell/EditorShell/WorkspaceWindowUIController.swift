
//  WorkspaceWindowUIController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EditorModel
import EditorCommon
import EditorUICommon

public final class WorkspaceWindowUIController: CommonWindowController, SessionProtocol, NSWindowDelegate {

	public override init() {
		// I don't know why, but configured "current appearance" disappears 
		// at some point, and I have to set them again for every time I make
		// a new window...
		NSAppearance.setCurrentAppearance(NSAppearance(named: NSAppearanceNameVibrantDark))
		super.init()
		Debug.log("WorkspaceWindowUIController `\(self)` init")
	}
	deinit {
		Debug.log("WorkspaceWindowUIController `\(self)` deinit")
	}








	///

	/// Will be set by upper level node.
	public weak var model: WorkspaceModel? {
		didSet {
			_tools.model	=	model
			_div.model	=	model
		}
	}
	











	///

	public func run() {
		assert(model != nil)
		assert(model!.location != nil)

		_reconfigureWindowAppearanceBehaviors()
		assert(window!.appearance != nil)
		assert(window!.appearance!.name == NSAppearanceNameVibrantDark)
		assert(NSAppearance.currentAppearance().name == NSAppearanceNameVibrantDark)

		window!.restorationClass	=	_RestorationManager.self
//		window!.releasedWhenClosed	=	false	// Trigger it's owner to release it.
		_div.view.frame			=	CGRect(origin: CGPoint.zero, size: _getMinSize())
		window!.contentViewController	=	_div

		///

		_installWindowAgent()
		_installToolbar()

		window!.delegate		=	_agent
		window!.makeKeyAndOrderFront(nil)

		model!.overallUIState.mutate {
			$0.navigationPaneVisibility	=	true
			$0.inspectionPaneVisibility	=	false
			$0.consolePaneVisibility	=	true
		}
	}
	public func halt() {
		assert(model != nil)

		window!.orderOut(self)
		
		window!.delegate		=	nil
		window!.contentViewController	=	nil
		_deinstallToolbar()
		_deinstallWindowAgent()
	}






























	///

	private let	_agent		=	_Agent()
	private let	_div		=	DivisionUIController2()
	private let	_tools		=	ToolUIController()

	private func _reconfigureWindowAppearanceBehaviors() {
		window!.collectionBehavior	=	NSWindowCollectionBehavior.FullScreenPrimary
		window!.styleMask		|=	NSClosableWindowMask
						|	NSResizableWindowMask
						|	NSMiniaturizableWindowMask
		window!.titleVisibility		=	.Hidden

		window!.setContentSize(_getMinSize())
		window!.minSize			=	window!.frame.size
		window!.setFrame(_getInitialFrameForScreen(window!.screen!, size: window!.minSize), display: false)

		let	USE_DARK_MODE	=	true
		if USE_DARK_MODE {
			assert(window != nil)
//			window!.titlebarAppearsTransparent	=	true
			window!.appearance	=	NSAppearance(named: NSAppearanceNameVibrantDark)
			window!.invalidateShadow()

			func makeDark(b:NSButton, _ alpha:CGFloat) {
				let	f	=	CIFilter(name: "CIColorMonochrome")!
				f.setDefaults()
//				f.setValue(CIColor(red: 0.5, green: 0.3, blue: 0.5, alpha: alpha), forKey: "inputColor")		//	I got this number accidentally, and I like this tone.
				f.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: alpha), forKey: "inputColor")
//
//				let	f1	=	CIFilter(name: "CIGammaAdjust")!
//				f1.setDefaults()
//				f1.setValue(0.3, forKey: "inputPower")
//
//				let	f2	=	CIFilter(name: "CIColorInvert")!
//				f2.setDefaults()

				b.contentFilters	=	[f]
			}
			makeDark(window!.standardWindowButton(NSWindowButton.CloseButton)!, 1.0)
			makeDark(window!.standardWindowButton(NSWindowButton.MiniaturizeButton)!, 1.0)
			makeDark(window!.standardWindowButton(NSWindowButton.ZoomButton)!, 1.0)
		}
	}
	private func _installWindowAgent() {
		_agent.owner		=	self
	}
	private func _deinstallWindowAgent() {
		_agent.owner		=	nil
	}
	private func _installToolbar() {
		assert(window!.toolbar === nil)
		_tools.run()
		window!.toolbar		=	_tools.toolbar
	}
	private func _deinstallToolbar() {
		assert(window!.toolbar === _tools.toolbar)

		window!.toolbar		=	nil
		_tools.halt()
	}

//	private func _becomeCurrentWorkspace() {
////		if model!.application.currentWorkspace.value !== self {
//////			if model!.application.currentWorkspace.value != nil {
//////				model!.application.deselectCurrentWorkspace()
//////			}
//////			model!.application.selectCurrentWorkspace(model!)
//////			model!.application.reselectCurrentWorkspace(model!)
////		}
//
//		Event.DidBecomeCurrent.dualcastAsNotificationWithSender(self)
//	}
//	private func _resignCurrentWorkspace() {
//		Event.WillResignCurrent.dualcastAsNotificationWithSender(self)
//
////		assert(model!.application.currentWorkspace.value === self)
////		model!.application.reselectCurrentWorkspace
////		markUnimplemented()
//	}
	private func _closeCurrentWorkspace() {
		model!.application.closeWorkspace(model!)
	}
}



















































private final class _Agent: NSObject, NSWindowDelegate {
	weak var owner: WorkspaceWindowUIController?
	@objc
	private func window(window: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplicationPresentationOptions) -> NSApplicationPresentationOptions {
		//	http://stackoverflow.com/questions/9263573/nstoolbar-shown-when-entering-fullscreenmode
		return	NSApplicationPresentationOptions([
			.FullScreen,
			.AutoHideToolbar,
			.AutoHideMenuBar,
			.AutoHideDock,
			])
	}

	@objc
	private func windowDidBecomeMain(notification: NSNotification) {
		assert(owner!.model!.application.currentWorkspace === nil)
		owner!.model!.application.currentWorkspace	=	owner!.model!
	}
	@objc
	private func windowDidResignMain(notification: NSNotification) {
		// It's impossible to assume specific state becuase this notification is broadcasted.
		if owner!.model!.application.currentWorkspace === owner!.model! {
			owner!.model!.application.currentWorkspace	=	nil
		}
	}

	@objc
	private func windowWillClose(notification: NSNotification) {
		owner!._closeCurrentWorkspace()
	}


	@objc
	private func window(window: NSWindow, willEncodeRestorableState state: NSCoder) {
		let	url	=	owner!.model!.location!
		let	code	=	url.absoluteString
		let	data	=	code.dataUsingEncoding(NSUTF8StringEncoding)!
		state.encodeBytes(unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self), length: data.length, forKey: _WINDOW_STATE_KEY_V0_MODEL_LOCATION)
//		let	data	=	try! owner!.model!.location!.bookmarkDataWithOptions([], includingResourceValuesForKeys: nil, relativeToURL: nil)
//		state.encodeBytes(unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self), length: data.length, forKey: _WINDOW_STATE_KEY_V0_MODEL_LOCATION)
	}

}







private func _getInitialFrameForScreen(screen: NSScreen, size: CGSize) -> CGRect {
	let	f	=	CGRect(origin: screen.frame.midPoint, size: CGSize.zero)
	let	insets	=	NSEdgeInsets(top: -size.height/2, left: -size.width/2, bottom: -size.height/2, right: -size.width/2)
	let	f2	=	insets.insetRect(f)
	return	f2
}
private func _getMinSize() -> CGSize {
	return	CGSize(width: 600, height: 300)
}















private let	_WINDOW_STATE_KEY_V0_MODEL_LOCATION	=	"v0/model.location"























private class _RestorationManager: NSObject, NSWindowRestoration {
	@objc
	class func restoreWindowWithIdentifier(identifier: String, state: NSCoder, completionHandler: (NSWindow?, NSError?) -> Void) {
		var	len	:	Int	=	0
		let	ptr	=	state.decodeBytesForKey(_WINDOW_STATE_KEY_V0_MODEL_LOCATION, returnedLength: &len)
		let	data	=	NSData(bytes: ptr, length: len)
		do {
			let	code	=	NSString(data: data, encoding: NSUTF8StringEncoding)! as String
			let	url	=	NSURL(string: code)!
//			let	url	=	try NSURL(byResolvingBookmarkData: data, options: [], relativeToURL: nil, bookmarkDataIsStale: nil)
			ApplicationUIController.theApplicationUIController!.model!.openWorkspaceAtURL(url)
			for workspace in ApplicationUIController.theApplicationUIController!.model!.workspaces {
				if workspace.location! == url {
					let	doc	=	ApplicationUIController.theApplicationUIController!.workspaceDocumentForModel(workspace)
					completionHandler(doc.workspaceWindowUIController.window!, nil)
					return
				}
			}
		}
		catch let error as NSError {
			completionHandler(nil, error)
		}
		completionHandler(nil, nil)
		checkAndReportFailureToDevelopers(false)
	}
}




