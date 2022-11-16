//
//  WheresMoApp.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import FirebaseCore
import SwiftUI

// Firebase initialization code
class AppDelegate: NSObject, UIApplicationDelegate {
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct WheresMoApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var loginViewModel = LoginViewModel()
    
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
            MapView() { loginViewModel.logout() }
        } else {
            LoginView()
                .environmentObject(loginViewModel)
        }
    }
}
