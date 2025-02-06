// Copyright © 2025 Marko Justinek. All rights reserved.

import Foundation

enum Utils {

    static func getProjectRoot() -> String {
        // Get the full file path of the current test file
        let currentFilePath = URL(fileURLWithPath: #file)

        // Traverse up to remove "Tests" and any subdirectories
        let projectRootPath = currentFilePath
            .deletingLastPathComponent() // Remove current file name /Utils.swift
            .deletingLastPathComponent() // Remove "Pact-ConcurrencyTests" folder name
            .path // Convert back to a string

        return projectRootPath
    }
}
