//
//  Report.swift
//  Editor6
//
//  Created by Hoon H. on 2016/10/09.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

func reportFatalError() -> Never  {
    fatalError()
}
func reportFatalError(_ message: String) -> Never  {
    fatalError(message)
}

