//
//  Path.DirectoryEnumerationOptions+Helpers.swift
//  XcodeFolderSync
//
//  Created by Nicolas Gomollon on 6/24/25.
//  Copyright © 2025 Techno-Magic. All rights reserved.
//

import Foundation
import PathKit

extension Path.DirectoryEnumerationOptions {
	
	///
	/// An option to perform a shallow enumeration in a directory and skip hidden
	/// files.
	///
	public static var shallowEnumeration: Path.DirectoryEnumerationOptions {
		return [
			Path.DirectoryEnumerationOptions(rawValue: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants.rawValue),
			Path.DirectoryEnumerationOptions(rawValue: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles.rawValue),
		]
	}
	
}
