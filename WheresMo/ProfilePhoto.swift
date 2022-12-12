//
//  ProfilePhoto.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/8/22.
//

import Combine
import CryptoKit
import FirebaseStorage
import Kingfisher
import SwiftUI

struct ProfilePhoto: View {
    let email: String
    let showUpdateProfilePhotoButton: Bool
    
    @StateObject private var viewModel: ProfilePhotoViewModel
    
    @State private var selectedProfilePhotoData: Data? = nil
    @State private var showingNewProfilePhotoAlert = false
    
    init(email: String, showUpdateProfilePhotoButton: Bool = false) {
        self.email = email
        self.showUpdateProfilePhotoButton = showUpdateProfilePhotoButton
        self._viewModel = StateObject(wrappedValue: ProfilePhotoViewModel(email: email))
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
        ZStack {
            switch viewModel.profilePhotoLoadingState {
            case .loading:
                ProgressView()
            case .loaded:
                viewModel.profilePhotoToShow!
                    .resizable()
                    .clipShape(Circle())
            case .failed:
                Image("Mo_background_removed")
                    .resizable()
                    .background(LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())
            }
            
            if showUpdateProfilePhotoButton {
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        PhotoSelector(label: selectProfilePhotoLabel, selectedPhotoData: $selectedProfilePhotoData)
                            .onChange(of: selectedProfilePhotoData) { item in
                                showingNewProfilePhotoAlert = true
                            }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProfilePhoto()
            }
        }
        .alert("Set new profile photo?", isPresented: $showingNewProfilePhotoAlert) {
            Button("Confirm") {
                Task {
                    guard self.selectedProfilePhotoData != nil else {
                        print("Could not save new profile photo, photo data was nil.")
                        return
                    }
                    try await viewModel.onProfilePhotoChange(newProfilePhotoData: self.selectedProfilePhotoData!)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Previous profile photo will be overwritten.")
        }
    }
}

struct FirebaseProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhoto(email: User.exampleUser.email, showUpdateProfilePhotoButton: true)
    }
}
