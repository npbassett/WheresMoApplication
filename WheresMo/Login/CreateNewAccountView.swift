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
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Enter Email", text: $loginViewModel.email)
                            .focused($isInputActive)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Email")
                    } footer: {
                        if loginViewModel.emailInvalid {
                            (Text(Image(systemName: "x.circle")) + Text(" Please enter a valid email address")).foregroundColor(.red)
                        } else {
                            (Text(Image(systemName: "checkmark.circle")) + Text(" Valid email address")).foregroundColor(.green)
                        }
                    }
                    
                    Section {
                        TextField("Enter Display Name", text: $loginViewModel.displayName)
                            .focused($isInputActive)
                    } header: {
                        Text("Display Name")
                    } footer: {
                        if loginViewModel.displayNameEmpty {
                            (Text(Image(systemName: "x.circle")) + Text(" Please enter a display name")).foregroundColor(.red)
                        } else if loginViewModel.displayNameTooLong {
                            (Text(Image(systemName: "x.circle")) + Text(" Display name must be less than 20 characters")).foregroundColor(.red)
                        } else {
                            (Text(Image(systemName: "checkmark.circle")) + Text(" Valid display name")).foregroundColor(.green)
                        }
                    }
                    
                    Section {
                        SecureField("Enter Password", text: $loginViewModel.password)
                            .focused($isInputActive)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Password")
                    }
                    
                    Section {
                        SecureField("Re-enter Password", text: $loginViewModel.passwordReentry)
                            .focused($isInputActive)
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
                    .disabled(loginViewModel.emailInvalid || loginViewModel.displayNameEmpty || loginViewModel.displayNameTooLong || loginViewModel.passwordTooShort || loginViewModel.passwordsDontMatch)
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        isInputActive = false
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
