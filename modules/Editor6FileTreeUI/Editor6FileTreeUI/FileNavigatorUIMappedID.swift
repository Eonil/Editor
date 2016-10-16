//
//  FileNavigatorUIMappedID.swift
//  Editor6FileTreeUI
//
//  Created by Hoon H. on 2016/10/15.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class FileNavigatorUIMappedID: NSObject {
    let sourceID: FileNavigatorUINodeID
    init(sourceID: FileNavigatorUINodeID) {
        self.sourceID = sourceID
    }
}

