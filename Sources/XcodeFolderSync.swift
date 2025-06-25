//
//  XcodeFolderSync.swift
//  XcodeFolderSync
//
//  Created by Nicolas Gomollon on 6/23/25.
//  Copyright © 2025 Techno-Magic. All rights reserved.
//

import Foundation
import ArgumentParser
import PathKit
import XcodeProj

@main
public struct XcodeFolderSync: ParsableCommand {
    
    public enum Error: LocalizedError {
        case groupNotFound
        case invalidTargetName
        case resourcesBuildPhaseNotFound
    }
    
    @Option(name: [.short, .customLong("project")], help: "The path of the project’s `.xcodeproj` file.", completion: .default)
    public var projectPath: String
    
    @Option(name: .shortAndLong, help: "The path of the folder to sync with the Xcode group, relative to the project file.", completion: .default)
    public var syncPath: String
    
    @Option(name: [.short, .customLong("target")], parsing: .singleValue, help: "The name of the target to add the files to. Specify multiple times to add the files to more than one target.")
    public var targetName: [String]
    
    public init() {}
    
    public func run() throws {
        let curProjectPath: Path = Path(projectPath)
        Path.current = curProjectPath.parent().absolute()
        
        let curSyncPath: Path = Path(syncPath)
        let syncPathComponents: [String] = curSyncPath.components
        
        let xcodeproj: XcodeProj = try XcodeProj(path: curProjectPath)
        guard let group: PBXGroup = xcodeproj.pbxproj.groups.first(where: { (group: PBXGroup) in
            switch group.sourceTree {
            case .sourceRoot:
                // Relative to Project
                guard group.name == syncPathComponents.last else { return false }
                if group.path == syncPath {
                    return true
                } else if let lastSeparator: String.Index = syncPath.lastIndex(where: { $0 == Character(Path.separator) }),
                   group.path == String(syncPath[syncPath.startIndex..<lastSeparator]) {
                    return true
                } else {
                    return false
                }
            case .group:
                // Relative to Group
                return group.name == syncPathComponents.last
            default:
                return false
            }
        }) else {
            throw Error.groupNotFound
        }
        print("Syncing folder with Xcode group: `\(syncPath)`")
        print()
        
        // Resolve the sync path, following a symbolic link if necessary, and
        // enumerate all files in the destination folder, ensuring the resulting
        // file paths are mapped to the original sync path location
        let folder: [Path]
        if let symlinkPath: Path = try? curSyncPath.symlinkDestination() {
            folder = symlinkPath.iterateChildren(options: .shallowEnumeration).map({ (curSyncPath + $0.lastComponent).absolute() })
        } else {
            folder = curSyncPath.iterateChildren(options: .shallowEnumeration).map(\.self)
        }
        
        // Find the differences between the folder in the filesystem and the
        // group in Xcode, syncing the changes to the group to match the
        // filesystem
        let delta: Delta<PBXFileReference> = try sync(group: group, folder: folder)
        
        // Sort the files in the group by name, mimicking the behavior in Xcode
        group.children.sort(by: XcodeSortByFileName)
        
        // Add files to the “Copy Bundle Resources” Build Phase for each
        // specified target
        for target in targetName {
            guard let nativeTarget: PBXNativeTarget = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == target }) else {
                throw Error.invalidTargetName
            }
            try updateResourcesBuildPhaseIn(nativeTarget: nativeTarget, delta: delta)
        }
        
        // Remove remaining file references for deleted files
        for fileRef in xcodeproj.pbxproj.fileReferences {
            guard delta.removed.contains(fileRef.uuid) else { continue }
            xcodeproj.pbxproj.delete(object: fileRef)
        }
        
        // Save the updated project
        try xcodeproj.write(path: curProjectPath)
        print("Successfully processed files for target(s): `\(targetName.joined(separator: "`, `"))`")
    }
    
    private func sync(group: PBXGroup, folder: [Path]) throws -> Delta<PBXFileReference> {
        var delta: Delta<PBXFileReference> = .init()
        print("Removed files:")
        group.children.removeAll { (child: PBXFileElement) in
            guard let childPath: Path = child.absolutePath(),
                  !folder.contains(childPath) else { return false }
            delta.remove(item: child)
            print(" - `\(child.name ?? "nil")`")
            return true
        }
        print()
        print("Added files:")
        for item in folder {
            guard !group.children.contains(where: { $0.absolutePath() == item }) else { continue }
            let file: PBXFileReference = try group.addFile(at: item, sourceRoot: .current, override: false, validatePresence: false)
            delta.add(item: file)
            print(" + `\(file.name ?? "nil")`")
        }
        print()
        return delta
    }
    
    private func updateResourcesBuildPhaseIn(nativeTarget: PBXNativeTarget, delta: Delta<PBXFileReference>) throws {
        guard let resourcesBuildPhase: PBXResourcesBuildPhase = try nativeTarget.resourcesBuildPhase() else {
            throw Error.resourcesBuildPhaseNotFound
        }
        resourcesBuildPhase.files?.removeAll { (buildFile: PBXBuildFile) in
            guard let file: PBXFileElement = buildFile.file,
                  delta.removed.contains(file.uuid) else { return false }
            return true
        }
        for file in delta.added {
            guard file.lastKnownFileType != "sourcecode.module-map" else { continue }
            _ = try resourcesBuildPhase.add(file: file)
        }
    }
    
}
