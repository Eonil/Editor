//
//  Apply.swift
//  Editor4
//
//  Created by Hoon H. on 2016/04/30.
//  Copyright © 2016 Eonil. All rights reserved.
//


extension State {
    mutating func apply(action: Action) throws {
        switch action {
        case .Reset:
            self = State()

        case .Test(let action):
            apply(action)

        case .Shell(let action):
            applyOnShell((), action: action)

        case .Workspace(let id, let action):
            try apply(id , action: action)

        case .ApplyCargoServiceState(let state):
            services.cargo = state
        }
    }

    private mutating func apply(action: TestAction) {
        switch action {
        case .Test1:
            print("Test1")

        case .Test2CreateWorkspaceAt(let u):
//            cargo
            break
        }
    }

    /// Shell is currently single, so it doesn't have an actual ID,
    /// but an ID is required to be passed to shape interface consistent.
    private mutating func applyOnShell(id: (), action: ShellAction) {
        MARK_unimplemented()
    }
    private mutating func apply(id: WorkspaceID, action: WorkspaceAction) throws {
        switch action {
        case .Open:
            workspaces[id] = WorkspaceState()

        case .SetCurrent:
            currentWorkspaceID = id

        case .Reconfigure(let location):
            workspaces[id]?.location = location

        case .Close:
            workspaces[id] = nil

        case .File(let action):
            try applyOnWorkspace(&workspaces[id]!, action: action)

        default:
            MARK_unimplemented()
        }
    }
    private mutating func applyOnWorkspace(inout workspace: WorkspaceState, action: FileAction) throws {
        switch action {
        case .CreateFolder(let container, let index):
            guard let newFolderName = (0..<128)
                .map({ "(new folder" + $0.description + ")" })
                .filter({ workspace.queryFile(container, containsSubfileWithName: $0) == false })
                .first else { throw OperationError.File(FileOperationError.CannotMakeNameForNewFolder) }
            let newFolderState = FileState2(form: FileForm.Container,
                                            phase: FilePhase.Editing,
                                            name: newFolderName)
            try workspace.files.insert(newFolderState, at: index, to: container)

        case .SetCurrent(let maybeNewFileID):
            workspace.window.navigatorPane.file.current = maybeNewFileID

        case .StartEditing(let fileID):
            workspace.window.navigatorPane.file.editing = fileID

        default:
            MARK_unimplemented()
        }
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension WorkspaceState {
    func queryFile(superfileID: FileID2, containsSubfileWithName subfileName: String) -> Bool {
        return files[superfileID].subfileIDs.contains { files[$0].name == subfileName }
    }
}





































