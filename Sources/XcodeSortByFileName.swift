//
//  XcodeSortByFileName.swift
//  XcodeFolderSync
//
//  Created by Nicolas Gomollon on 6/24/25.
//  Copyright © 2025 Techno-Magic. All rights reserved.
//

import Foundation
import XcodeProj

public func XcodeSortByFileName(fileA: PBXFileElement, fileB: PBXFileElement) -> Bool {
    switch (fileA.name, fileB.name) {
    case (.some(let fileNameA), .some(let fileNameB)):
        let componentsA: [String] = fileNameA.components(separatedBy: ".")
        let componentsB: [String] = fileNameB.components(separatedBy: ".")
        let compared: [Bool] = zip(componentsA, componentsB).map({ $0.caseInsensitiveCompare($1) == .orderedSame })
        if compared[0] {
            return componentsA.count < componentsB.count
        } else {
            return fileNameA.caseInsensitiveCompare(fileNameB) == .orderedAscending
        }
    case (.some, nil):
        return true
    case (nil, .some),
         (nil, nil):
        return false
    }
}
