//
//  Report.swift
//  Editor6
//
//  Created by Hoon H. on 2016/10/09.
//  Copyright © 2016 Eonil. All rights reserved.
//

@available(*, deprecated: 0.0.0, message: "Rename to `REPORT_...` pattern.")
public func reportFatalError() -> Never  {
    fatalError()
}
@available(*, deprecated: 0.0.0, message: "Rename to `REPORT_...` pattern.")
public func reportFatalError(_ message: String) -> Never  {
    fatalError(message)
}

