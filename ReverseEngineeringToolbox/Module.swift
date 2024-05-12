//
//  Module.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/17.
//

import AppKit

enum Module: Int, CaseIterable, Hashable, Identifiable {
    case classDump
    case utilities

    var id: Self { self }

    var title: String {
        switch self {
        case .classDump:
            return "ClassDump"
        case .utilities:
            return "Utilities"
        }
    }
}
