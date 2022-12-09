//
//  FirebaseProfilePhoto.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/8/22.
//

import Combine
import CryptoKit
import FirebaseStorage
import Kingfisher
import SwiftUI

struct FirebaseProfilePhoto: View {
    var email: String
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            switch viewModel.profilePhotoLoadingState {
            case .loading:
                ProgressView()
            case .loaded:
                viewModel.profilePhotoToShow!
                    .resizable()
            case .failed:
                Image("Mo_background_removed")
                    .resizable()
                    .background(LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .task {
            await viewModel.fetchProfilePhoto(email: email)
        }
    }
}

struct FirebaseProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseImage(id: UUID(uuidString: "383401B4-675B-4A04-B73B-BC1FEFB8997E")!)
    }
}
