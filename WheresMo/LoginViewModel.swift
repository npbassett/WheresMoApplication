//
//  LoginView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/15/22.
//

import Firebase
import SwiftUI

class LoginViewModel: ObservableObject {
    @ObservedObject var dataManager: DataManager
    @Published var email = ""
    @Published var displayName = ""
    @Published var password = ""
    @Published var passwordReentry = ""
    @Published var userLoggedInEmail: String? = nil
    @Published var showingLoginError = false
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    var emailInvalid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return !emailPredicate.evaluate(with: email)
    }
    
    var displayNameEmpty: Bool {
        displayName.isEmpty
    }
    
    var displayNameTooLong: Bool {
        displayName.count > 20
    }
    
    var passwordsDontMatch: Bool {
        password != passwordReentry
    }
    
    var passwordTooShort: Bool {
        password.count < 8
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                self.userLoggedInEmail = self.email
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
                self.dataManager.addUser(user: User(email: self.email, displayName: self.displayName))
                
                self.email = ""
                self.displayName = ""
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
            userLoggedInEmail = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
