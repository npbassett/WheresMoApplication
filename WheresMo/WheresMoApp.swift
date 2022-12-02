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
    @StateObject private var loginViewModel = LoginViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            view()
                .environmentObject(loginViewModel)
        }
    }
}

extension WheresMoApp {
    @ViewBuilder
    private func view() -> some View {
        if loginViewModel.userLoggedIn != nil {
            MainView(userLoggedIn: loginViewModel.userLoggedIn!) { loginViewModel.logout() }
        } else {
            LoginView()
                .environmentObject(loginViewModel)
        }
    }
}
