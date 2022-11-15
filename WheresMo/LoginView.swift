//
//  LoginView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/14/22.
//

import Firebase
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showingCreateNewAccount = false
    
    var body: some View {
        if isLoggedIn {
            MapView()
        } else {
            loginScreen
        }
    }
    
    var loginScreen: some View {
        ZStack {
            LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Where's Mo?")
                    .foregroundColor(.white)
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
                        TextField("Email", text: $email)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .padding()
                            .background(.white)
                            .cornerRadius(5)
                            .padding(.bottom)
                        
                        SecureField("Password", text: $password)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .padding()
                            .background(.white)
                            .cornerRadius(5)
                            .padding(.bottom)
                        
                        Button {
                            login()
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
                    }
                    .padding()
                }
                
                Button {
                    showingCreateNewAccount = true
                } label: {
                    Text("Don't have an account? Click here.")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
            }
            .padding()
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        isLoggedIn = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateNewAccount) {
            CreateNewAccountView()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
