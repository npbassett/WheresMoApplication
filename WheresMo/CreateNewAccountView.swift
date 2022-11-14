//
//  CreateNewAccountView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/14/22.
//

import Firebase
import SwiftUI

struct CreateNewAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var passwordReentry = ""
    
    private var passwordsDontMatch: Bool {
        password != passwordReentry
    }
    private var emailEmpty: Bool {
        email.isEmpty
    }
    private var passwordTooShort: Bool {
        password.count < 8
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Enter Email", text: $email)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Email")
                    }
                    
                    Section {
                        SecureField("Enter Password", text: $password)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Password")
                    }
                    
                    Section {
                        SecureField("Re-enter Password", text: $passwordReentry)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Confirm Password")
                    } footer: {
                        VStack(alignment: .leading) {
                            if passwordsDontMatch {
                                (Text(Image(systemName: "x.circle")) + Text(" Passwords do not match")).foregroundColor(.red)
                            } else {
                                (Text(Image(systemName: "checkmark.circle")) + Text(" Passwords match")).foregroundColor(.green)
                            }
                            
                            if passwordTooShort {
                                (Text(Image(systemName: "x.circle")) + Text(" Password must be at least 8 characters")).foregroundColor(.red)
                            } else {
                                (Text(Image(systemName: "checkmark.circle")) + Text(" Password is at least 8 characters")).foregroundColor(.green)
                            }
                        }
                    }
                    
                    Button {
                        createNewUser()
                        dismiss()
                    } label: {
                        Text("Create Account")
                    }
                    .disabled(emailEmpty || passwordTooShort || passwordsDontMatch)
                }
            }
            .navigationBarTitle("Create Account")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
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

struct CreateNewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewAccountView()
    }
}
