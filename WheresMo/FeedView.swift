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
        NavigationView {
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
                    ForEach(viewModel.locations, id: \.self.id) { location in
                        Section {
                            NavigationLink {
                                LocationDetailView(location: location,
                                                   userLoggedIn: viewModel.userLoggedIn,
                                                   onDeleteLocation: { viewModel.removeLocationFromList(location: location) },
                                                   onSaveLocation: { location in viewModel.updateLocationList(location: location) }
                                )
                            } label: {
                                FeedPostView(location: location)
                                    .onAppear {
                                        if location == viewModel.locations.last {
                                            Task {
                                                await viewModel.fetchLocations()
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(MainViewModel(userLoggedIn: User.exampleUser))
    }
}
