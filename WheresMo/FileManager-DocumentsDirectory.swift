//
//  FileManager-DocumentsDirectory.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
