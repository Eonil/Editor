//
//  Result.swift
//  Editor
//
//  Created by Hoon H. on 2017/06/16.
//  Copyright © 2017 Eonil. All rights reserved.
//

public enum Result<Value,Issue> {
    case failure(Issue)
    case success(Value)
}
