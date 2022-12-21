//
//  LocationPhoto.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/21/22.
//

import Combine
import FirebaseStorage
import Kingfisher
import SwiftUI

/// View displaying the photo (stored in Firebase Storage) associated with a location.
///
/// View should be initialized using location that is being shown. For example:
/// ```
/// FirebaseLocationPhoto(id: location.id)
/// ```
///
/// - note: If UUID is not found in Firebase Storage, locationPhotoLoadingState will be set to
///         failed and default Mo image will be shown.
struct LocationPhoto: View {
    let id: UUID
    @StateObject private var viewModel: LocationPhotoViewModel
    
    init(id: UUID) {
        self.id = id
        self._viewModel = StateObject(wrappedValue: LocationPhotoViewModel(id: id))
    }
    
    var body: some View {
        VStack {
            switch viewModel.locationPhotoLoadingState {
            case .loading:
                ProgressView()
            case .loaded:
                viewModel.photoToShow!
                    .resizable()
            case .failed:
                Image("Mo_background_removed")
                    .resizable()
                    .background(LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLocationPhoto()
            }
        }
    }
}

struct LocationPhoto_Previews: PreviewProvider {
    static var previews: some View {
        LocationPhoto(id: UUID())
    }
}
