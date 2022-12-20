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
    @Published var displayName = ""
    @Published var password = ""
    @Published var passwordReentry = ""
    @Published var userLoggedIn: User? = nil
    @Published var showingLoginError = false
    @Published var showingCreateUserError = false
    @Published var createUserErrorMessage = ""
    
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
                print("Successfully authenticated user!")
                
                let currentUser = Auth.auth().currentUser
                if currentUser != nil {
                    if currentUser!.displayName != nil {
                        print("Found displayName for \(self.email)!")
                        
                        self.userLoggedIn = User(email: self.email, displayName: currentUser!.displayName!)
                    } else {
                        print("Could not find displayName for \(self.email)!")
                        
                        self.userLoggedIn = User(email: self.email, displayName: "Unknown Name")
                    }
                } else {
                    print("Something went wrong! Firebase was able to authenticate user, but no user is currently logged in.")
                }
                
                self.email = ""
                self.password = ""
                self.passwordReentry = ""
            } else {
                print("Could not authenticate user: \(error!.localizedDescription)")
                self.showingLoginError = true
            }
        }
    }
    
    func createNewUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error == nil {
                print("Successfully created new user!")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                if let changeRequest {
                    changeRequest.displayName = self.displayName
                    changeRequest.commitChanges { error in
                        if error == nil {
                            print("Sucessfully saved displayName!")
                        } else {
                            print("Error saving displayName: \(error!.localizedDescription)")
//                            self.createUserErrorMessage = error!.localizedDescription
//                            self.showingCreateUserError.toggle()
                        }
                    }
                }
            } else {
                print("Error creating user: \(error!.localizedDescription)")
                self.createUserErrorMessage = error!.localizedDescription
                self.showingCreateUserError.toggle()
            }
            
            self.email = ""
            self.displayName = ""
            self.password = ""
            self.passwordReentry = ""
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
    
    func sendResetPasswordEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                print("Could not send password reset link: \(error!.localizedDescription)")
            } else {
                print("Sent password reset link!")
            }
        }
    }
}
