//
//  WheresMoApp.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import FirebaseCore
import Kingfisher
import SwiftUI

@main
struct WheresMoApp: App {
    @StateObject private var loginViewModel = LoginViewModel()
    
    init() {
        FirebaseApp.configure()
        
        // Limit Kingfisher image cache disk space to 500 MB
        ImageCache.default.diskStorage.config.sizeLimit = 500 * 1024 * 1024
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
