//
//  AppDelegate.swift
//  PrecompilationInteractiveWorkbench
//
//  Created by Hoon H. on 2015/01/11.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa
import Precompilation
import PrecompilationOfExternalToolSupport

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
//		UIDialogues.queryDeletingFilesUsingWindowSheet(window, files: [NSURL(string: "AA")!]) { (b:UIDialogueButton) -> () in
//			switch b {
//			case .OKButton:
//				println("OK")
//				
//			case .CancelButton:
//				println("Cancel")
//				
//			}
//		}

		
//		let	s	=	CargoExecutionController.build(NSURL(string: "file:///Users/Eonil/Documents/test1")!)

//		let	s	=	String(contentsOfFile: "/Users/Eonil/Workshop/Incubation/Editor/Project/Subprojects/Precompilation/PrecompilationUnitTest/example1.txt", encoding: NSUTF8StringEncoding, error: nil)!
//		let	ss	=	CargoOutputParser.parseErrorOutput(s)
//		
//		for s in ss {
//			println(s)
//		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

