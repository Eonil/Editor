//
//  ModelType.swift
//  EditorModel
//
//  Created by Hoon H. on 2015/10/26.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation

public protocol ModelType: class {
	typealias	Event: EventType
}





public protocol BroadcastingModelType: ModelType {
	var event: EventMulticast<Event> { get }
}