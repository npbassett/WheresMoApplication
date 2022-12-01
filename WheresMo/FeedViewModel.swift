//
//  FeedViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/1/22.
//

import Foundation
import SwiftUI

@MainActor class FeedViewModel: ObservableObject {
    @ObservedObject var dataManager: DataManager
    var userLoggedInEmail: String
    
    init(dataManager: DataManager, userLoggedInEmail: String) {
        self.dataManager = dataManager
        self.userLoggedInEmail = userLoggedInEmail
    }
}
