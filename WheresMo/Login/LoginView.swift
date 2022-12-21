//
//  LoginView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/14/22.
//

import Firebase
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingCreateNewAccount = false
    @State private var showingResetPassword = false
    @FocusState var isInputActive: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Where's Mo?")
                    .foregroundColor(Color(UIColor.systemBackground))
                    .font(.system(size: 40, weight: .bold))
                
                Image("Mo_background_removed")
                    .resizable()
                    .scaledToFit()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height: 250)
                        .shadow(radius: 10)
                    
                    VStack {
                        TextField("Email", text: $loginViewModel.email)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .focused($isInputActive)
                            .padding()
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(5)
                            .padding(.bottom)
                        
                        SecureField("Password", text: $loginViewModel.password)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .focused($isInputActive)
                            .padding()
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(5)
                            .padding(.bottom)
                        
                        Button {
                            loginViewModel.login()
                        } label: {
                            Text("Log In")
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 40)
                                .background {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(.blue)
                                }
                        }
                        .alert("Unable to log in.", isPresented: $loginViewModel.showingLoginError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Email and/or password is incorrect.")
                        }
                    }
                    .padding()
                }
                
                Button {
                    showingCreateNewAccount.toggle()
                } label: {
                    Text("Don't have an account? Click here.")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .underline()
                }
                .alert("Error creating user", isPresented: $loginViewModel.showingCreateUserError) {
                    Button("OK") { }
                } message: {
                    Text(loginViewModel.createUserErrorMessage)
                }
                
                Button {
                    showingResetPassword.toggle()
                } label: {
                    Text("Forgot Password?")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .underline()
                }
                .alert("Reset Password", isPresented: $showingResetPassword){
                    TextField("Email", text: $loginViewModel.email)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    Button("Send") {
                        loginViewModel.sendResetPasswordEmail(email: loginViewModel.email)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Please enter the email to send the password reset link.")
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    isInputActive = false
                }
            }
        }
        .sheet(isPresented: $showingCreateNewAccount) {
            CreateNewAccountView()
                .environmentObject(loginViewModel)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginViewModel())
    }
}
