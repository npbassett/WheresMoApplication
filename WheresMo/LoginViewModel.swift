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
    @Published var isLoggedIn = false
    
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
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func createNewUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
