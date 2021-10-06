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
                VStack(alignment: .center, spacing: 0) {
                    Circle()
                        .foregroundColor(.yellow)
                        .overlay(content: {
                            Text("🤔")
                                .font(.largeTitle)
                        })
                        .frame(width: 128, height: 128, alignment: .center)
                        .padding(.bottom)
                    Text("User Name")
                        .font(.body.bold())
                }.frame(maxWidth: .infinity)
                .padding()
                
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
            
            if debugMode {
                Section {
                    Text("SGMP \(Bundle.main.versionString ?? "NULL") (\(Bundle.main.buildString ?? "NULL"))")
                        .font(.caption.monospaced())
                    Text("User ID \(env.authUser?.userId ?? "NULL")")
                        .font(.caption.monospaced())
                    Text("Model \(UIDevice.current.model) (\(UIDevice.current.name))")
                        .font(.caption.monospaced())
                    Text("System \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                        .font(.caption.monospaced())
                } header: {
                    Text("Debug Info")
                }

            }

        }.navigationTitle("Settings")
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
