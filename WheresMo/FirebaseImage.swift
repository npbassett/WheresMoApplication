//
//  FirebaseImage.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/21/22.
//

import Combine
import FirebaseStorage
import SwiftUI

struct FirebaseImage: View {
    var id: UUID
    @State private var loadingState = LoadingState.loading
    @State private var imageToShow: UIImage? = nil
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                ProgressView()
            case .loaded:
                Image(uiImage: imageToShow!)
                    .resizable()
                    .scaledToFit()
            case .failed:
                Image("Mo_background_removed")
                    .resizable()
                    .scaledToFit()
                VStack {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.red)
                    Text("Fetching image failed.")
                }
                .padding()
                
            }
        }
        .task {
            await fetchImage(id: id)
        }
    }
    
    func fetchImage(id: UUID) async {
        let url = "gs://wheresmo-415ab.appspot.com/images/\(id.uuidString).jpg"
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                loadingState = .failed
            } else {
                imageToShow = UIImage(data: data!)
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
        FirebaseImage(id: UUID())
    }
}
