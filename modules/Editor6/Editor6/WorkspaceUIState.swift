//
//  WorkspaceUIState.swift
//  Editor6
//
//  Created by Hoon H. on 2016/10/09.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import Editor6FileTreeUI

struct WorkspaceUIState {
    var fileNavigator = FileNavigatorUIState()
    var issueNavigator = ()
    var debugNavigator = ()
    var logNavigator = ()
}
