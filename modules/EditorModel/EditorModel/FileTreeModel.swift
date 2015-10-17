//
//  FileTreeModel.swift
//  EditorModel
//
//  Created by Hoon H. on 2015/08/29.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import MulticastingStorage
import EditorCommon

/// `FileTreeModel` manages file tree.
///
/// A file-system on Unix-like systems is always a remote storage.
/// That means all operations are asynchronous at core level regardless
/// of high level interfaces. So you cannot get a synchronous state 
/// query or specific state guarantee. All operations are done in 
/// try-and-see manner. You just issue a command and see what happens.
///
/// All file operations are provided in synchronous interface only for 
/// your convenience, and you'll get result synchronously. All file operations
/// `return` on success, and `throw` on failure.
///
/// Anyway, non-file-operations are not written in this manner. For 
/// example, file view node management are fully predictable and synchronous,
/// so it can be asserted, and checked regardless of file operations.
///
/// Internally, this class maintains a `WorkspaceItemTree` instance to 
/// track file item list.
///
public class FileTreeModel: ModelSubnode<WorkspaceModel> {


	struct Error: ErrorType {
		enum Code {
			case CannotMoveDueToLackOfNodeAtFromPath
			case CannotMoveDueToExistingNodeAtToPath
		}
		
		var	code	:	Code
		var	message	:	String
	}

	///

	deinit {
		assert(_isInstalled == false)
	}

	///

	public var workspace: WorkspaceModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}

	override func didJoinModelRoot() {
		super.didJoinModelRoot()
		_install()
	}
	override func willLeaveModelRoot() {
		_deinstall()
		super.willLeaveModelRoot()
	}

	///

	public let	selection	=	FileSelectionModel()

	///

	public var root: ValueStorage<FileNodeModel?> {
		get {
			return	_root
		}
	}
//	public var isBusy: ValueStorage<Bool> {
//		get {
//			return	_isBusy
//		}
//	}
	public var storing: CompletionChannel {
		get{
			return	_storing
		}
	}
	public var restoring: CompletionChannel {
		get {
			return	_restoring
		}
	}

	/// Fired for each time tree node structure changed.
	/// Currently, there's no way to track precise changes
	/// because it's complex and I don't feel need for it
	/// now. Maybe later.
	public var onDidChange: ValueStorage<()> {
		get {
			return	_onDidChange
		}
	}

	///

	public func runRestoringSnapshot() {
		let	u	=	_snapshotFileURL()
		_restoreSnapshotFromURL(u)
		_onDidChange.value	=	()
	}
	public func runStoringSnapshot() {
		let	u	=	_snapshotFileURL()
		_storeSnapshotToURL(u)
	}

	///

	public func containsNodeAtPath(path: WorkspaceItemPath) -> Bool {
		return	_findNodeForPath(path) != nil
	}

	public func createFolderAtPath(path: WorkspaceItemPath) throws {
		assert(_checkDBAndTreeSynhronicity())
		assert(_findNodeForPath(path) == nil, "There's already a node at the path `\(path)`.")

		let	containerPath	=	path.pathByDeletingLastComponent()

		// Creates all intermediate directories.
		if _tree.root.findNodeForPath(containerPath) != nil {
			try createFolderAtPath(containerPath)
		}

		let	fu	=	path.absoluteFileURL(`for`: workspace)
		do {
			try Platform.thePlatform.fileSystem.createDirectoryAtURL(fu, recursively: false)
		}
		catch let error as PlatformFileSystemError where error == .AlreadyExists {
			// Just ignore it.
		}
		catch let error {
			throw error
		}

		assert(_tree.root.findNodeForPath(containerPath) != nil)
		_insertNodeAtPath(path)

		_onDidChange.value	=	()
	}
	public func deleteFolderAtPath(path: WorkspaceItemPath) throws {
		markUnimplemented()

		_onDidChange.value	=	()
	}
	public func createFileAtPath(path: WorkspaceItemPath) throws {
		let	fu	=	path.absoluteFileURL(`for`: workspace)
		do {
			try Platform.thePlatform.fileSystem.createFileAtURL(fu)
			_insertNodeAtPath(path)

		}
		catch {
			markUnimplemented()
		}

		_onDidChange.value	=	()
	}
	public func deleteFileAtPath(path: WorkspaceItemPath) {
		_deleteNodeAtPath(path)

		_onDidChange.value	=	()
	}

	///

	private let	_root	=	MutableValueStorage<FileNodeModel?>(nil)
	private var	_tree	=	WorkspaceItemTree()
//	private let	_isBusy	=	MutableValueStorage<Bool>(false)

	private let	_storing	=	CompletionQueue()
	private let	_restoring	=	CompletionQueue()

	private var	_isInstalled	=	false

	private let	_onDidChange	=	MutableValueStorage<()>(())

	///

	private func _install() {
		Debug.assertMainThread()
		assert(_root.value == nil)
		assert(_isInstalled == false)

		selection.owner		=	self

		_tree.createRoot()
		_installRoot(_rebuildFileNodeModelTree(self, _tree))

		_isInstalled		=	true
	}
	private func _deinstall() {
		Debug.assertMainThread()
		assert(_root.value != nil)
		assert(_isInstalled == true)

		_deinstallRoot()
		_tree.deleteRoot()

		selection.owner		=	nil

		_isInstalled		=	false
	}

	/// Installs a new root node from database.
	/// 
	/// This method MUST be called in main thread.
	private func _installRoot(node: FileNodeModel) {
		Debug.assertMainThread()
		assert(_root.value === nil)

		node._path.value	=	WorkspaceItemPath.root
		node._comment.value	=	_tree.root.comment
		node.owner		=	self
		_root.value		=	node

		_onDidChange.value	=	()
	}
	/// This method MUST be called in main thread.
	private func _deinstallRoot() {
		Debug.assertMainThread()
		assert(_root.value !== nil)

		let	node		=	_root.value!
		_root.value		=	nil
		node.owner		=	nil
		node._comment.value	=	nil
		node._path.value	=	nil

		_onDidChange.value	=	()
	}

	///

	private func _restoreSnapshotFromURL(u: NSURL) {
		do {
			let	data	=	try Platform.thePlatform.fileSystem.contentOfFileAtURLAtomically(u)
			if let s = NSString(data: data, encoding: NSUTF8StringEncoding) as String? {
				let	tree	=	try! WorkspaceItemTree(snapshot: s)
				let	node	=	_rebuildFileNodeModelTree(self, tree)

				dispatchToMainQueueAsynchronously() { [weak self] in
					guard self != nil else {
						return
					}
					self!._deinstallRoot()
					self!._tree	=	tree
					self!._installRoot(node)
				}
			}
			else {
				assert(false, "Could not read a valid UTF-8 string from file `\(u)`.")
				markUnimplemented()
			}
		}
		catch let error as NSError {
			assert(false, "Could not find file `\(u)`. An error `\(error)` occured.")
			markUnimplemented()
		}
	}
	private func _storeSnapshotToURL(u: NSURL) {
		let	s	=	_tree.snapshot()
		Debug.log("Storing snapshot `\(s)`...")
		let	d	=	s.dataUsingEncoding(NSUTF8StringEncoding)!
		do {
			try Platform.thePlatform.fileSystem.replaceContentOfFileAtURLAtomically(u, data: d)
		}
		catch let error as NSError {
			assert(false, "Could not write to file `\(u)`. An error `\(error)` occured.")
			markUnimplemented()
		}
	}

	private func _snapshotFileURL() -> NSURL {
		Debug.assertMainThread()
		assert(workspace.location.value != nil)
		return	workspace.location.value!.URLByAppendingPathComponent("Workspace.EditorFileList")
	}

	///

//	/// Throws an exception if there's already a node at the `to` path.
//	/// Throws an exception if there's no node at the `from` path.
//	private func _moveNodeAtPath(from: WorkspaceItemPath, to: WorkspaceItemPath) throws {
//		guard from != to else {
//			// Just treat it done.
//			return
//		}
//
//		guard _db.containsItemForPath(from) == true else {
//			throw Error(code: FileTreeModel.Error.Code.CannotMoveDueToLackOfNodeAtFromPath, message: "There's no node at the `from` path `\(from)`.")
//		}
//		guard _db.containsItemForPath(to) == false else {
//			throw Error(code: FileTreeModel.Error.Code.CannotMoveDueToExistingNodeAtToPath, message: "There's already a node at the `to` path `\(to)`.")
//		}
//
//		_db.deleteItemAtPath(from)
//		_db.insertItemAtPath
//	}

	private func _insertNodeAtPath(path: WorkspaceItemPath) {
		Debug.assertMainThread()
		assert(_checkDBAndTreeSynhronicity())
		assert(_findNodeForPath(path) == nil, "There's already a node at the path `\(path)`.")

		let	containerPath	=	path.pathByDeletingLastComponent()
		assert(_tree.root.findNodeForPath(containerPath) != nil)

		if let node = _findNodeForPath(containerPath) {
			let	item	=	WorkspaceItemNode(name: path.parts.last!, isGroup: false)
			_tree.root.findNodeForPath(containerPath)!.subnodes.append(item)

			let	newnode		=	FileNodeModel()
			newnode.owner		=	self
			newnode.supernode	=	node
			newnode._path.value	=	path
			node._subnodes.append(newnode)

			assert(_checkDBAndTreeSynhronicity())
			return
		}
		else {
			fatalError("There's no container node at path `\(containerPath)`. Cannot insert a new node at path `\(path)`.")
		}
	}
	private func _deleteNodeAtPath(path: WorkspaceItemPath) {
		Debug.assertMainThread()
		assert(path != WorkspaceItemPath.root)

		if let node = _findNodeForPath(path) {
			if let supernode = node.supernode {
				if let idx = supernode.subnodes.array.indexOfValueByReferentialIdentity(node) {
					supernode._subnodes.delete(idx...idx)
					let	item	=	_tree.root.findNodeForPath(path)!
					item.supernode!.subnodes.remove(item)

					assert(_checkDBAndTreeSynhronicity())
					return
				}
			}
		}
		assert(false)
	}


	///

	private func _findNodeForPath(path: WorkspaceItemPath) -> FileNodeModel? {
		Debug.assertMainThread()
		return	_root.value?._findNodeForPath(path)
	}

	///

	private func _checkDBAndTreeSynhronicity() -> Bool {
		Debug.assertMainThread()
		if let root = _root.value {
			return	_checkDBAndTreeSynhronicityAtNode(root, path: WorkspaceItemPath.root)
		}
		else {
			return	_tree.root.count == 0
		}
	}
	private func _checkDBAndTreeSynhronicityAtNode(node: FileNodeModel, path: WorkspaceItemPath) -> Bool {
		Debug.assertMainThread()
		guard _tree.root.findNodeForPath(path) != nil else {
			assert(false)
			return	false
		}

		guard node.path.value == path else {
			assert(false)
			return	false
		}

		///

		let	subnodes	=	node.subnodes.array
		let	subpaths	=	_tree.root.findNodeForPath(path)!.subnodes.map({ $0.resolvePath() })

		guard subnodes.count == subpaths.count else {
			assert(false)
			return	false
		}

		for i in subnodes.wholeRange {
			let	subnode	=	subnodes[i]
			let	subpath	=	subpaths[i]

			guard _tree.root.findNodeForPath(subpath.pathByDeletingLastComponent()) != nil else {
				assert(false)
				return	false
			}

			let	ok	=	_checkDBAndTreeSynhronicityAtNode(subnode, path: subpath)

			guard ok else {
				assert(false)
				return	false
			}
		}

		return	true
	}
}


//
//public protocol FileTreeModelDelegate {
//	func willInsertNodesAtPaths()
//	func didInsertNodesAtPaths()
//	func willUpdateNodesAtPaths()
//	func didUpdateNodesAtPaths()
//	func willDeleteNodesAtPaths()
//	func didDeleteNodesAtPaths()
//}
//

































/// NO LAZY LOADING RIGHT NOW. UNIMPLEMENTED YET.
///
/// You must manually `loadSubnodes` subnodes before accesing `subnode` property.
/// Also you must manually call `unloadSubodes` when you don't use them anymore
/// to save memory.
///
public class FileNodeModel: ModelSubnode<FileTreeModel> {

	deinit {
		assert(_isInstalled == false)
	}

	///

	public var tree: FileTreeModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}

	public private(set) weak var supernode: FileNodeModel?

	///

	override func didJoinModelRoot() {
		super.didJoinModelRoot()
		_install()
	}
	override func willLeaveModelRoot() {
		_deinstall()
		super.willLeaveModelRoot()
	}

	///

	public var path: ValueStorage<WorkspaceItemPath?> {
		get {
			return	_path
		}
	}
	public var comment: ValueStorage<String?> {
		get {
			return	_comment
		}
	}
	public var subnodes: ArrayStorage<FileNodeModel> {
		get {
			precondition(_isLoaded == true)
			return	_subnodes
		}
	}

	///

//	public func relocate(location: WorkspaceItemPath) throws {
//		precondition(supernode != nil)
//
//		let	containerNodePath	=	location.pathByDeletingLastComponent()
//		let	maybeContainerNode	=	tree._findNodeForPath(containerNodePath)
//		checkAndReportFailureToDevelopers(maybeContainerNode != nil)
//		if let containerNode = maybeContainerNode {
//			containerNode._insertSubnodes([], at: 0)
//		}
//
//		_path.value	=	location
//	}

	///

	private let	_path		=	MutableValueStorage<WorkspaceItemPath?>(nil)
	private let	_comment	=	MutableValueStorage<String?>(nil)
	private let	_subnodes	=	MutableArrayStorage<FileNodeModel>([])
	private var	_isLoaded	=	true
	internal var	_isInstalled	=	false

	///

	private func _install() {
		assert(_isInstalled == false)

		for subnode in subnodes.array {
			assert(subnode.owner === nil)
			subnode.owner	=	owner!
		}

		_isInstalled	=	true
	}
	private func _deinstall() {
		assert(_isInstalled == true)

		for subnode in subnodes.array {
			assert(subnode.owner === owner!)
			subnode.owner	=	nil
		}

		_isInstalled	=	false
	}

	private func _insertSubnodes(subnodes: [FileNodeModel], at index: Int) {
		_subnodes.insert(subnodes, atIndex: index)
		for subnode in subnodes {
			subnode.owner		=	owner!
			subnode.supernode	=	self
		}
	}
	private func _deleteSubnodeInRange(range: Range<Int>) {
		for subnode in _subnodes.array[range] {
			subnode.supernode	=	nil
			subnode.owner		=	nil
		}
		_subnodes.delete(range)
	}
//	private func _moveSubnodeToPath(toPath: WorkspaceItemPath, from fromPath: WorkspaceItemPath) {
//		_subnodes
//	}

	/// This searches only in subtree including self.
	private func _findNodeForPath(path: WorkspaceItemPath) -> FileNodeModel? {
		if let selfPath = _path.value {
			if path == selfPath {
				return	self
			}
			for subnode in _subnodes.array {
				if let subpath = subnode.path.value {
					if path.hasPrefix(subpath) {
						return	subnode._findNodeForPath(path)
					}
				}
			}
		}

		return	nil
	}
}



















/// Can be executed on any thread.
private func _rebuildFileNodeModelTree(modelTree: FileTreeModel, _ snapshotTree: WorkspaceItemTree) -> FileNodeModel {
	return	_rebuildFileNodeModelSubtree(modelTree, snapshotTree, `for`: WorkspaceItemPath.root)
}
/// Can be executed on any thread.
///
/// - Parameters:
///	- tree
///		This object will not be accessed at all, and only its pointer will be used to each subnodes.
///
private func _rebuildFileNodeModelSubtree(modelTree: FileTreeModel, _ snapshotTree: WorkspaceItemTree, `for` path: WorkspaceItemPath) -> FileNodeModel {
	let	node		=	FileNodeModel()
	node._path.value	=	path
	node._comment.value	=	snapshotTree.root.findNodeForPath(path)!.comment
	node.owner		=	modelTree

	let	subpaths	=	snapshotTree.root.findNodeForPath(path)!.subnodes.map({ $0.resolvePath() })
	var	subnodes	=	[FileNodeModel]()
	subnodes.reserveCapacity(subpaths.count)
	for subpath in subpaths {
		let	subnode		=	_rebuildFileNodeModelSubtree(modelTree, snapshotTree, `for`: subpath)
		subnode.supernode	=	node
		subnodes.append(subnode)
	}
	node._subnodes.extend(subnodes)
	return	node
}






//internal func TEST_STUB_rebuildFileNodeModelTree(modelTree: FileTreeModel, _ snapshotTree: WorkspaceItemTree) -> FileNodeModel {
//	return	_rebuildFileNodeModelTree(modelTree, snapshotTree)
//}
//extension FileTreeModel {
//	internal func TEST_STUB_restoreSnapshotFromURL(u: NSURL) {
//		_restoreSnapshotFromURL(u) {}
//	}
//}














