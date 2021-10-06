//
//  SettingsTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import Defaults
import SwiftUI
import Amplify

struct SettingsTabView: View {
    @EnvironmentObject var env : Env
    @Default(.debugMode) var debugMode
    
    var body: some View {
        List {
            
            Section {
                Text("Username \(env.authUser?.username ?? "")")
                
                Button {
                    Amplify.Auth.signOut() { result in
                        switch result {
                        case .success:
                            print("Successfully signed out")
                        case .failure(let error):
                            print("Sign out failed with error \(error)")
                        }
                    }
                } label: {
                    Text("Logout")
                }
            } header: {
                Text("User")
            }
            
            Section {
                NavigationLink("About", destination: AboutAppView())
                Toggle(isOn: $debugMode) {
                    Text("Debug")
                }
            } header: {
                Text("Misc")
            }

        }.navigationTitle("Settings")
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
