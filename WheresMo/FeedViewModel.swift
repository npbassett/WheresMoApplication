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
    var userLoggedIn: User
    
    init(dataManager: DataManager, userLoggedIn: User) {
        self.dataManager = dataManager
        self.userLoggedIn = userLoggedIn
    }
}
