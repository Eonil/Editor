//
//  PreferenceModel.swift
//  EditorModel
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation

/// Manages app-global preference.
///
public class PreferenceModel: ModelSubnode<ApplicationModel> {

	override func didJoinModelRoot() {
		super.didJoinModelRoot()
	}
	override func willLeaveModelRoot() {
		super.willLeaveModelRoot()
	}

	///

	public var application: ApplicationModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}
}
