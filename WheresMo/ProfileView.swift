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
    
    @State private var selectedProfilePhotoData: Data? = nil
    @State private var showingNewProfilePhotoAlert = false
    
    init(userToShow: User, userLoggedIn: User, navigatedFromMainView: Bool, onLogout: @escaping () -> Void) {
        self.userToShow = userToShow
        self.userLoggedIn = userLoggedIn
        self.navigatedFromMainView = navigatedFromMainView
        self.onLogout = onLogout
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userToShow: userToShow,
                                                                     userLoggedIn: userLoggedIn,
                                                                     navigatedFromMainView: navigatedFromMainView))
    }
    
    var selectProfilePhotoLabel: AnyView {
        return AnyView(
            Image(systemName: "plus")
                .font(.title)
                .padding(5)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .padding(.trailing)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    // TODO: reload after changing profile photo
                    FirebaseProfilePhoto(email: userToShow.email)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .environmentObject(viewModel)
                    
                    if viewModel.userLoggedInProfile {
                        HStack {
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                PhotoSelector(label: selectProfilePhotoLabel, selectedPhotoData: $selectedProfilePhotoData)
                                    .onChange(of: selectedProfilePhotoData) { item in
                                        showingNewProfilePhotoAlert = true
                                    }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
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
                            LocationDetailView(location: location)
                        } label: {
                            FirebaseImage(id: location.id)
                                .frame(width: 170, height: 170)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                }
                .padding(0)
                
                Spacer()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLocationsByUser(user: userToShow)
            }
        }
        .alert("Set new profile photo?", isPresented: $showingNewProfilePhotoAlert) {
            Button("Confirm") {
                Task {
                    try await profilePhotoChanged()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Previous profile photo will be overwritten.")
        }
    }
    
    func profilePhotoChanged() async throws {
        guard selectedProfilePhotoData != nil else {
            return
        }
        print("Setting new profile photo.")
        await viewModel.saveProfilePhoto(data: selectedProfilePhotoData!, email: viewModel.userLoggedIn.email)
        await viewModel.clearProfilePhotoCache(email: userToShow.email)
        try await Task.sleep(for: .seconds(0.5))
        await viewModel.fetchProfilePhoto(email: userToShow.email)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userToShow: User.exampleUser, userLoggedIn: User.exampleUser, navigatedFromMainView: true, onLogout: { })
    }
}
