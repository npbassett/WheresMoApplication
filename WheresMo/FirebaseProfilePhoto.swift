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
    @State private var loadingState = LoadingState.loading
    @State private var imageToShow: KFImage? = nil
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                ProgressView()
            case .loaded:
                imageToShow!
                    .resizable()
            case .failed:
                Image("Mo_background_removed")
                    .resizable()
                    .background(LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .task {
            await fetchProfilePhoto(email: email)
        }
    }
    
    func fetchProfilePhoto(email: String) async {
        loadingState = .loading
        
        let emailHash = SHA256.hash(data: Data(email.utf8)).description
        let ref = Storage.storage().reference(withPath: "profilePhotos/\(emailHash).jpg")
        ref.downloadURL { url, error in
            if let error {
                print("Error fetching image: \(error.localizedDescription)")
                loadingState = .failed
            } else {
                imageToShow = KFImage(url!)
                loadingState = .loaded
            }
        }
    }
}

struct FirebaseProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseImage(id: UUID(uuidString: "383401B4-675B-4A04-B73B-BC1FEFB8997E")!)
    }
}
