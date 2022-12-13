//
//  ProfileView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct ProfileView: View {
    var userToShow: User
    var userLoggedIn: User
    var navigatedFromMainView: Bool
    var onLogout: () -> Void = { }
    
    @StateObject private var viewModel: ProfileViewModel
    
    init(userToShow: User, userLoggedIn: User, navigatedFromMainView: Bool, onLogout: @escaping () -> Void) {
        self.userToShow = userToShow
        self.userLoggedIn = userLoggedIn
        self.navigatedFromMainView = navigatedFromMainView
        self.onLogout = onLogout
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userToShow: userToShow,
            userLoggedIn: userLoggedIn, navigatedFromMainView: navigatedFromMainView))
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title)
                                .padding(.trailing)
                        }
                    }
                    
                    Spacer()
                }
                
                VStack {
                    ProfilePhoto(email: userToShow.email, showUpdateProfilePhotoButton: viewModel.userLoggedInProfile)
                        .frame(width: 150, height: 150)
                    
                    Text(userToShow.displayName)
                        .font(.title)
                        .bold()
                    
                    if viewModel.userLoggedInProfile {
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
                            NavigationLink {
                                LocationDetailView(location: location,
                                                   userLoggedIn: viewModel.userLoggedIn,
                                                   onDeleteLocation: { viewModel.removeLocationFromList(location: location)},
                                                   onSaveLocation: { location in viewModel.updateLocationList(location: location) })
                            } label: {
                                LocationPhoto(id: location.id)
                                    .frame(width: 170, height: 170)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                    }
                    .padding(0)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLocationsPlacedByUser()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userToShow: User.exampleUser, userLoggedIn: User.exampleUser, navigatedFromMainView: true, onLogout: { })
    }
}
