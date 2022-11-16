//
//  LoginView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/15/22.
//

import Firebase
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordReentry = ""
    @Published var userLoggedIn: User? = nil
    @Published var showingLoginError = false
    
    var passwordsDontMatch: Bool {
        password != passwordReentry
    }
    var emailEmpty: Bool {
        email.isEmpty
    }
    var passwordTooShort: Bool {
        password.count < 8
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                self.userLoggedIn = User(email: self.email)
                self.email = ""
                self.password = ""
                self.passwordReentry = ""
            } else {
                print(error!.localizedDescription)
                self.showingLoginError = true
            }
        }
    }
    
    func createNewUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error == nil {
                self.email = ""
                self.password = ""
                self.passwordReentry = ""
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            print("logging out")
            userLoggedIn = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
