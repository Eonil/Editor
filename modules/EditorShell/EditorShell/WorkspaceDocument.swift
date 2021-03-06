//
//  WorkspaceDocument.swift
//  EditorDriver
//
//  Created by Hoon H. on 2015/08/15.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EditorCommon

@objc
public class WorkspaceDocument: NSDocument {


	public let	workspaceWindowUIController	=	WorkspaceWindowUIController()



	public override init() {
		super.init()
		Debug.log("WorkspaceDocument `\(self)` init.")
	}
	deinit {
		Debug.log("WorkspaceDocument `\(self)` deinit.")
	}

	///

	public override func makeWindowControllers() {
		super.makeWindowControllers()
		addWindowController(workspaceWindowUIController)
	}

	public override class func autosavesInPlace() -> Bool {
		return true
	}

//	override func dataOfType(typeName: String) throws -> NSData {
//		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
//		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//	}

	public override func readFromURL(url: NSURL, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	public override func writeToURL(url: NSURL, ofType typeName: String) throws {
		//	Nothing to do.
	}





}


