//
//  FirebaseImage.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/21/22.
//

import Combine
import FirebaseStorage
import Kingfisher
import SwiftUI

struct FirebaseImage: View {
    var id: UUID
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
            await fetchImage(id: id)
        }
    }
    
    func fetchImage(id: UUID) async {
        let ref = Storage.storage().reference(withPath: "images/\(id.uuidString).jpg")
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

enum LoadingState {
    case loading, loaded, failed
}

struct FirebaseImage_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseImage(id: UUID(uuidString: "383401B4-675B-4A04-B73B-BC1FEFB8997E")!)
    }
}
