//
//  MainView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct MainView: View {
    var userLoggedIn: User
    var onLogout: () -> Void
    
    @StateObject private var viewModel: MainViewModel
    
    init(userLoggedIn: User, onLogout: @escaping () -> Void) {
        self.userLoggedIn = userLoggedIn
        self.onLogout = onLogout
        self._viewModel = StateObject(wrappedValue: MainViewModel(userLoggedIn: userLoggedIn))
    }
    
    var body: some View {
        TabView {
            FeedView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }
            
            MapView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            ProfileView(userToShow: userLoggedIn, onLogout: onLogout)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .onAppear {
            viewModel.fetchLocations()
            
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(userLoggedIn: User.exampleUser, onLogout: { })
    }
}
