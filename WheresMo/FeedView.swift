//
//  FeedView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/30/22.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var dataManager: DataManager
    var userLoggedInEmail: String
    
    @StateObject private var viewModel: FeedViewModel
    
    init(dataManager: DataManager, userLoggedInEmail: String) {
        self.dataManager = dataManager
        self.userLoggedInEmail = userLoggedInEmail
        self._viewModel = StateObject(wrappedValue: FeedViewModel(dataManager: dataManager, userLoggedInEmail: userLoggedInEmail))
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
            .padding(.bottom)
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
        FeedView(dataManager: DataManager(), userLoggedInEmail: User.exampleUser.email)
    }
}
