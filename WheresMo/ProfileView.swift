//
//  ProfileView.swift
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
    
    @State private var selectedProfilePhotoData: Data? = nil
    @State private var showingNewProfilePhotoAlert = false
    
    var userLoggedInProfile: Bool {
        return userToShow == viewModel.userLoggedIn && navigatedFromMainView
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
                    
                    if userLoggedInProfile {
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
                    .padding()
                    .font(.title)
                    .bold()
                
                if userLoggedInProfile {
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
            Task {
                await viewModel.fetchLocationsByUser(user: userToShow)
            }
        }
        .alert("Set new profile photo?", isPresented: $showingNewProfilePhotoAlert) {
            Button("Confirm") {
                Task {
                    await profilePhotoChanged()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Previous profile photo will be overwritten.")
        }
    }
    
    func profilePhotoChanged() async {
        guard selectedProfilePhotoData != nil else {
            return
        }
        print("Setting new profile photo.")
        await viewModel.saveProfilePhoto(data: selectedProfilePhotoData!, email: viewModel.userLoggedIn.email)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userToShow: User.exampleUser, navigatedFromMainView: true)
            .environmentObject(MainViewModel(userLoggedIn: User.exampleUser))
    }
}
