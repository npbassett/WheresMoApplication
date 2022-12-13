//
//  FeedView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/30/22.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    @State private var showingNewLocationSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                HStack {
                    Text("Mo Feed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        showingNewLocationSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                    .padding()
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
        .sheet(isPresented: $showingNewLocationSheet) {
            let location = Location(placedByUser: viewModel.userLoggedIn, latitude: 0.0, longitude: 0.0)
            NavigationView {
                LocationEditView(location: location, navigatedFromDetailView: false)
                    .environmentObject(LocationViewModel(location: location,
                                                         userLoggedIn: viewModel.userLoggedIn,
                                                         // Passing empty closure because new location is not in self.locations,
                                                         // so it does not need to be removed if deleted.
                                                         onDeleteLocation: { },
                                                         onSaveLocation: { location in viewModel.updateLocationList(location: location) })
                    )
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
