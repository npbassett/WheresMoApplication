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
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Enter Email", text: $loginViewModel.email)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Email")
                    }
                    
                    Section {
                        SecureField("Enter Password", text: $loginViewModel.password)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Password")
                    }
                    
                    Section {
                        SecureField("Re-enter Password", text: $loginViewModel.passwordReentry)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Confirm Password")
                    } footer: {
                        VStack(alignment: .leading) {
                            if loginViewModel.passwordsDontMatch {
                                (Text(Image(systemName: "x.circle")) + Text(" Passwords do not match")).foregroundColor(.red)
                            } else {
                                (Text(Image(systemName: "checkmark.circle")) + Text(" Passwords match")).foregroundColor(.green)
                            }
                            
                            if loginViewModel.passwordTooShort {
                                (Text(Image(systemName: "x.circle")) + Text(" Password must be at least 8 characters")).foregroundColor(.red)
                            } else {
                                (Text(Image(systemName: "checkmark.circle")) + Text(" Password is at least 8 characters")).foregroundColor(.green)
                            }
                        }
                    }
                    
                    Button {
                        loginViewModel.createNewUser()
                        dismiss()
                    } label: {
                        Text("Create Account")
                    }
                    .disabled(loginViewModel.emailEmpty || loginViewModel.passwordTooShort || loginViewModel.passwordsDontMatch)
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
}

struct CreateNewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewAccountView()
            .environmentObject(LoginViewModel())
    }
}
