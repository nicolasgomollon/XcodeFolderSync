//
//  PBXFileElement+Helpers.swift
//  XcodeFolderSync
//
//  Created by Nicolas Gomollon on 6/24/25.
//  Copyright © 2025 Techno-Magic. All rights reserved.
//

import Foundation
import PathKit
import XcodeProj

extension PBXFileElement {
    
    public func absolutePath() -> Path? {
        return try? fullPath(sourceRoot: .current)
    }
    
}
