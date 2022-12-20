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
    
    var body: some View {
        TabView {
            FeedView(userLoggedIn: userLoggedIn)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }
            
            MapView(userLoggedIn: userLoggedIn)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            NavigationView {
                ProfileView(userToShow: userLoggedIn, userLoggedIn: userLoggedIn, navigatedFromMainView: true, onLogout: onLogout)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(userLoggedIn: User.exampleUser, onLogout: { })
    }
}
