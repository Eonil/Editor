//
//  MainMenuActionItem.swift
//  Editor5
//
//  Created by Hoon H. on 2016/10/09.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class MainMenuActionItem: NSMenuItem {
    var actionToDispatch = MainMenuAction?.none
    @objc
    @available(*,unavailable)
    override var action: Selector? {
        willSet { fatalError() }
    }
}
