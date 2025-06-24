//
//  XcodeFolderSync.Delta.swift
//  XcodeFolderSync
//
//  Created by Nicolas Gomollon on 6/24/25.
//  Copyright © 2025 Techno-Magic. All rights reserved.
//

import Foundation
import XcodeProj

extension XcodeFolderSync {
    
    public struct Delta<T: PBXObject> {
        
        public private(set) var added: [T] = []
        public private(set) var removed: Set<String> = []
        
        public var isEmpty: Bool {
            return added.isEmpty && removed.isEmpty
        }
        
        public mutating func add(item: T) {
            added.append(item)
        }
        
        public mutating func remove(item: PBXObject) {
            removed.insert(item.uuid)
        }
        
    }
    
}
