//
//  UINotifications.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/10/25.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import EditorModel

public extension ApplicationUIController {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	ApplicationUIController
	}
}
public extension WorkspaceWindowUIController {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	WorkspaceWindowUIController
		case WillResignCurrent
		case DidBecomeCurrent
	}
}











internal protocol BroadcastableEventType: EventType {
	func broadcastWithSender(sender: Sender)
}
internal extension BroadcastableEventType {
	typealias	Notification	=	EditorModel.Notification<Sender, Self>
	func broadcastWithSender(sender: Sender) {
		Notification(sender, self).broadcast()
	}
}