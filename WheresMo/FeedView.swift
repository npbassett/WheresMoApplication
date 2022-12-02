//
//  FeedView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/30/22.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var dataManager: DataManager
    var userLoggedIn: User
    
    @StateObject private var viewModel: FeedViewModel
    
    init(dataManager: DataManager, userLoggedIn: User) {
        self.dataManager = dataManager
        self.userLoggedIn = userLoggedIn
        self._viewModel = StateObject(wrappedValue: FeedViewModel(dataManager: dataManager, userLoggedIn: userLoggedIn))
    }
    
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
                ForEach(dataManager.locations) { location in
                    Section {
                        FeedPostView(viewModel: viewModel, location: location)
                    }
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(dataManager: DataManager(), userLoggedIn: User.exampleUser)
    }
}
