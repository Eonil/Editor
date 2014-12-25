//
//  Debug.swift
//  RustCodeEditor
//
//  Created by Hoon H. on 11/13/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import EonilDispatch
struct Debug {
	static func logOnMainQueueAsynchronously<T>(v:@autoclosure()->T) {
		let	v2	=	v()
		async(Queue.main) {
			Debug.log(v2)
		}
	}
	static func log<T>(v:@autoclosure()->T) {
		println(v())
	}
}









func assertMainThread() {
	assert(NSThread.currentThread() == NSThread.mainThread())
}