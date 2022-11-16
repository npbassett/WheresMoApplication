//
//  User.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/15/22.
//

import Firebase
import Foundation

struct User: Codable {
    var email: String
    
    static let exampleUser = User(email: "test@test.com")
}
