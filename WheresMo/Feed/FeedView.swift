//
//  FeedView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/30/22.
//

import SwiftUI

struct FeedView: View {
    var userLoggedIn: User
    
    @StateObject private var viewModel: FeedViewModel
    
    @State private var showingNewLocationSheet = false
    
    init(userLoggedIn: User) {
        self.userLoggedIn = userLoggedIn
        self._viewModel = StateObject(wrappedValue: FeedViewModel(userLoggedIn: userLoggedIn))
    }
    
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
                .padding(.bottom, 5)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.primary.opacity(0.5))
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.locations, id: \.self.id) { location in
                            NavigationLink {
                                LocationDetailView(location: location,
                                                   userLoggedIn: viewModel.userLoggedIn,
                                                   onDeleteLocation: { viewModel.removeLocationFromList(location: location) },
                                                   onSaveLocation: { location in viewModel.updateLocationList(location: location) }
                                )
                            } label: {
                                FeedPostView(location: location)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.leading)
                                    .padding(.trailing)
                                    .onAppear {
                                        if location == viewModel.locations.last {
                                            Task {
                                                await viewModel.fetchLocations()
                                            }
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLocations()
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
        FeedView(userLoggedIn: User.exampleUser)
    }
}
