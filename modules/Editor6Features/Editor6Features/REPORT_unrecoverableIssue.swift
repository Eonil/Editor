//
//  REPORT_unrecoverableIssue.swift
//  Editor6Features
//
//  Created by Hoon H. on 2017/05/28.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Editor6Common

func REPORT_unrecoverableIssue<T>(_ v: T) -> Never {
    reportFatalError("\(v)")
}
