//
//  SettingsView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct ProfileView: View {
    var userToShow: User
    var navigatedFromMainView: Bool
    var onLogout: () -> Void = { }
    
    @EnvironmentObject var viewModel: MainViewModel
    
    var showingLogoutButton: Bool {
        return userToShow == viewModel.userLoggedIn && navigatedFromMainView
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Image("Mo_background_removed")
                    .resizable()
                    .padding(.top, 5)
                    .background(LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Text(userToShow.displayName)
                    .padding()
                    .font(.title)
                    .bold()
                
                if showingLogoutButton {
                    Button {
                        onLogout()
                    } label: {
                        (Text(Image(systemName: "rectangle.portrait.and.arrow.right")) + Text(" Log Out"))
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                }
                
                HStack {
                    Text("Recent Locations")
                    
                    Rectangle()
                        .foregroundColor(.primary.opacity(0.5))
                        .frame(height: 0.5)
                }
                .padding(.leading)
                .padding(.trailing)
                .foregroundColor(.primary.opacity(0.5))
                
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .trailing), GridItem(.flexible(), alignment: .leading)]) {
                    
                    ForEach(viewModel.locationsPlacedByUser) { location in
                        FirebaseImage(id: location.id)
                            .frame(width: 170, height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .padding(0)
                
                Spacer()
            }
        }
        .navigationTitle("Placed By")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchLocationsByUser(user: userToShow)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userToShow: User.exampleUser, navigatedFromMainView: true)
            .environmentObject(MainViewModel(userLoggedIn: User.exampleUser))
    }
}
