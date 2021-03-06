//
//  WorkspaceItemTree.swift
//  WorkspaceItemTree
//
//  Created by Hoon H. on 2015/10/17.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation

/// Manages workspace items.
///
/// Thread Consideration
/// --------------------
/// This class is single-thread only. Do not use this object from multiple
/// thread simultaneously. Anyway it's fine to use this from non-main thread.
///
public class WorkspaceItemTree {

	public init() {
	}

	///

	public var root: WorkspaceItemNode? {
		get {
			return	_root
		}
	}










	///

	internal func createRoot() {
		_root	=	WorkspaceItemNode(name: "workspace", isGroup: true)
	}
//	internal func createRootFromSnapshot() {
//	}
	internal func deleteRoot() {
		_root	=	nil
	}







	///

	private var	_root	:	WorkspaceItemNode?
}




























public class WorkspaceItemNode {

	public enum NameValidationError: ErrorType {
		case InvalidBecuaseTheNameIsEmptyString
		case InvalidBecuaseTheNameContainsSlash
		case InvalidBecuaseThereIsAnotherSiblingNodeWithTheName
	}

	/// You can a node with any name, but inserting node with invalid name 
	/// will throw an error.
	public init(name: String, isGroup: Bool) {
//		assertNoError(WorkspaceItemNode.validateName(name, withSupernode: nil))
		self.name	=	name
		self.isGroup	=	isGroup
	}

	///

	/// O(n) where n is number of total nodes in tree.
	public var count: Int {
		get {
			return	subnodes.map({ $0.count }).reduce(1, combine: +)
		}
	}
	public internal(set) var name: String {
		willSet {
			assertNoError(WorkspaceItemNode.validateName(newValue, withSupernode: _supernode))
		}
		didSet {
		}
	}

	public internal(set) var isGroup: Bool = false {
		willSet {
			assert(newValue == true || subnodes.count == 0, "You cannot convert this node into a non-group node if there's any subnode.")
		}
		didSet {
		}
	}

	public internal(set) var comment: String? {
		willSet {
		}
		didSet {
		}
	}

	public var supernode: WorkspaceItemNode? {
		get {
			return	_supernode
		}
	}
	public var subnodes: WorkspaceItemSubnodeList {
		get {
			return	WorkspaceItemSubnodeList(host: self)
		}
	}

	public func resolvePath() -> WorkspaceItemPath {
		if let supernode = _supernode {
			return	supernode.resolvePath().pathByAppendingLastComponent(name)
		}
		else {
			return	WorkspaceItemPath.root
		}
	}

	/// Find destination node by evaluating the path.
	///
	/// - Parameters:
	///	- path
	///		A path is always absolute. This method just treats current node
	///		as a root node.
	///
	public func searchNodeForPath(path: WorkspaceItemPath) -> WorkspaceItemNode? {
//		precondition(supernode == nil, "You can call this only on root node. (no supernode)")
		if path.parts.count == 0 {
			return	self
		}
		else {
			let	subname	=	path.parts.first!
			let	subpath	=	WorkspaceItemPath(parts: Array(path.parts[1..<path.parts.count]))

			if let subnode = subnodes[subname] {
				return	subnode.searchNodeForPath(subpath)
			}
			else {
				return	nil
			}
		}
	}





	///

	public static func validateName(name: String, withSupernode supernode: WorkspaceItemNode?)() throws {
		return	try _validateName(name, withSupernode: supernode)
	}






	///

	private weak var	_supernode	:	WorkspaceItemNode?
	private var		_subnodes	=	[WorkspaceItemNode]()

	private static func _validateName(name: String, withSupernode supernode: WorkspaceItemNode?) throws {
		guard name != "" else {
			throw	WorkspaceItemNode.NameValidationError.InvalidBecuaseTheNameIsEmptyString
		}
		guard name.containsString("/") == false else {
			throw	WorkspaceItemNode.NameValidationError.InvalidBecuaseTheNameContainsSlash
		}
		guard supernode == nil || supernode!.subnodes[name] == nil else {
			throw	WorkspaceItemNode.NameValidationError.InvalidBecuaseThereIsAnotherSiblingNodeWithTheName
		}
	}
}






















public struct WorkspaceItemSubnodeList: SequenceType {

	private init(host: WorkspaceItemNode) {
		_host	=	host
	}








	///

	public var count: Int {
		get {
			return	_host!._subnodes.count
		}
	}

	/// O(1) at best, O(n) at worst where n == count.
	public func indexForName(name: String) -> Int? {
		for i in 0..<count {
			let	subnode	=	_host!._subnodes[i]
			if subnode.name == name {
				return	i
			}
		}
		return	nil
	}

	/// O(1).
	public subscript(index: Int) -> WorkspaceItemNode {
		get {
			return	_host!._subnodes[index]
		}
	}

	/// O(1) at best, O(n) at worst where n == count.
	public subscript(name: String) -> WorkspaceItemNode? {
		get {
			if let idx = indexForName(name) {
				return	_host!._subnodes[idx]
			}
			return	nil
		}
	}









	///

	public func generate() -> Array<WorkspaceItemNode>.Generator {
		return	_host!._subnodes.generate()
	}










	///

	/// Appends a node at the end of list.
	///
	/// This is equivalent with `insert(node, atIndex: count)`.
	internal func append(node: WorkspaceItemNode) {
		insert(node, atIndex: count)
	}

	/// Inserts a node at specified position.
	///
	/// You must provide node with only valid names.
	/// Use `WorkspaceItemNode.validateName` to check name validity.
	internal func insert(node: WorkspaceItemNode, atIndex index: Int) {
		assert(node._supernode == nil, "The node `\(node)` is already a subnode of this node.")
		assert(_host!.isGroup == true, "You cannot insert a subnode to a non-group node.")
		assertNoError(WorkspaceItemNode.validateName(node.name, withSupernode: _host!))
		_host!._subnodes.insert(node, atIndex: index)
		node._supernode	=	_host
	}

	internal func remove(node: WorkspaceItemNode) {
		guard let idx = _host!._subnodes.indexOfValueByReferentialIdentity(node) else {
			fatalError("Cannot find specified node in this node.")

		}
		removeAtIndex(idx)
	}

	internal func removeAtIndex(index: Int) {
		let	node	=	_host!._subnodes[index]
		assert(node._supernode === _host, "The node `\(node)` is not a subnode of this node.")
		node._supernode	=	nil
		_host!._subnodes.removeAtIndex(index)
	}
	







	///

	private weak var	_host	:	WorkspaceItemNode?
}










































func assertNoError(@noescape code: () throws ->()) {
	assert({ ()->Bool in
		if let error = catchAnyError(code) {
			fatalError("An error `\(error)` has been thrown while executing code.")
		}
		return	true
		}())
}

func catchAnyError(@noescape code: () throws ->()) -> ErrorType? {
	do {
		try code()
	}
	catch let error {
		return	error
	}
	return	nil
}










