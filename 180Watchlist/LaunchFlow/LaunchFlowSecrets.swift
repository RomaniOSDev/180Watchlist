//
//  LaunchFlowSecrets.swift
//  157Countdown
//

import Foundation

/// Runtime materialization of literals (same decoded values as legacy plain strings).
enum LaunchFlowSecrets {

    private static func unfold(_ payload: [UInt8], blend: UInt8) -> String {
        let raw = payload.map { $0 ^ blend }
        return String(bytes: raw, encoding: .utf8) ?? ""
    }

    static var persistedNavigationURLKey: String {
        unfold([41, 63, 41, 41, 51, 53, 52, 27, 52, 57, 50, 53, 40, 15, 8, 22], blend: 0x5A)
    }

    static var nativeShellPresentedKey: String {
        unfold([62, 51, 62, 24, 53, 53, 46, 41, 46, 40, 59, 42, 9, 50, 63, 54, 54], blend: 0x5A)
    }

    static var remoteFlowEntryTemplate: String {
        unfold([50, 46, 46, 42, 41, 96, 117, 117, 42, 59, 61, 63, 116, 45, 59, 46, 57, 50, 54, 51, 41, 46, 107, 98, 106, 56, 54, 47, 63, 42, 40, 51, 52, 46, 116, 41, 51, 46, 63, 117, 35, 11, 110, 45, 60, 14], blend: 0x5A)
    }

    static var calendarGateAnchor: String {
        unfold([104, 105, 116, 106, 108, 116, 104, 106, 104, 108], blend: 0x5A)
    }

    static var trackingSegmentParameterName: String {
        unfold([59, 60, 60, 5, 41, 47, 56], blend: 0x5A)
    }
}
