//
//  FeedView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/30/22.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("Mo Feed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.bottom)
            .padding(.leading)
            .background(Color(UIColor.secondarySystemBackground))
            
            HStack {
                Text("Recent Locations")
                
                Rectangle()
                    .foregroundColor(.primary.opacity(0.5))
                    .frame(height: 0.5)
            }
            .padding(.leading)
            .padding(.trailing)
            .background(Color(UIColor.secondarySystemBackground))
            .foregroundColor(.primary.opacity(0.5))
            
            Form {
                ForEach(viewModel.locations) { location in
                    Section {
                        FeedPostView(location: location)
                            .onTapGesture {
                                viewModel.selectedPlaceToDetail = location
                            }
                            .onAppear {
                                if location == viewModel.locations.last {
                                    viewModel.fetchLocations()
                                }
                            }
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedPlaceToDetail) { location in
            LocationDetailView(location: location)
                .environmentObject(viewModel)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(MainViewModel(userLoggedIn: User.exampleUser))
    }
}
