//
//  WheresMoApp.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import FirebaseCore
import SwiftUI

@main
struct WheresMoApp: App {
    @StateObject private var dataManager: DataManager
    @StateObject private var loginViewModel: LoginViewModel
    
    init() {
        FirebaseApp.configure()
        let dataManager = DataManager()
        self._dataManager = StateObject(wrappedValue: dataManager)
        self._loginViewModel = StateObject(wrappedValue: LoginViewModel(dataManager: dataManager))
    }
    
    var body: some Scene {
        WindowGroup {
            view()
                .environmentObject(dataManager)
                .environmentObject(loginViewModel)
        }
    }
}

extension WheresMoApp {
    @ViewBuilder
    private func view() -> some View {
        if loginViewModel.userLoggedInEmail != nil {
            MainView(dataManager: DataManager(), userLoggedInEmail: loginViewModel.userLoggedInEmail!) { loginViewModel.logout() }
        } else {
            LoginView()
                .environmentObject(loginViewModel)
        }
    }
}
