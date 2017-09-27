//
//  LogFeature.swift
//  Editor
//
//  Created by Hoon H. on 2017/06/15.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Foundation

final class LogFeature: ServicesDependent {
    let signal = Relay<()>()
    let changes = Relay<[Change]>()
    private(set) var state = State()

    func process(_ cmd: InternalCommand) {
        switch cmd {
        case .startBuildSession:
            guard state.currentBuildSession == nil else {
                REPORT_ignoredSignal(cmd)
                break
            }
            state.currentBuildSession = State.BuildSession()
            changes.cast([.currentBuildSession])
        case .endBuildSession:
            guard let bs = state.currentBuildSession else {
                REPORT_ignoredSignal(cmd)
                break
            }
            state.archivedBuildSessions.append(bs)
            state.currentBuildSession = nil
            changes.cast([.currentBuildSession, .archivedBuildSessions])
        case .setBuildState(let s):
            guard var bs = state.currentBuildSession else {
                REPORT_ignoredSignal(cmd)
                break
            }
            let items = [
                s.session.production.reports.map(Item.cargoReport),
                s.session.production.issues.map(Item.cargoIssue),
            ].joined()
            bs.items = Array(items)
            state.currentBuildSession = bs
            changes.cast([.currentBuildSession])
        }
    }
}
extension LogFeature {
    struct State {
        var currentBuildSession: BuildSession?
        var archivedBuildSessions = [BuildSession]()

        struct BuildSession {
            var items = [Item]()
        }
    }
    enum Item {
        case cargoReport(CargoProcess2.Report)
        case cargoIssue(CargoProcess2.Issue)
    }
//    struct Item {
//        var timestamp: Date
//        var severity: Severity
//        var message: String
//        var subsystem: String
//        var category: String
//    }
//    enum Severity {
//        /// Verbose messages for debugging.
//        case debug
//        /// Informative message.
//        case info
//        /// Recoverable issue.
//        case warning
//        /// Process-wide failure.
//        case error
//        /// System-wide failure.
//        case fault
//    }

    enum InternalCommand {
        case startBuildSession
        case endBuildSession
        case setBuildState(BuildFeature.State)
    }
    enum Change {
        case currentBuildSession
        case archivedBuildSessions
    }
}
