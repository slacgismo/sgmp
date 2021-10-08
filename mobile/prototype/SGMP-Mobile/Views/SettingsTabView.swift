//
//  SettingsTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import Defaults
import SwiftUI
import Amplify
import Kingfisher

struct SettingsTabView: View {
    @EnvironmentObject var env : Env
    @Default(.debugMode) var debugMode
    @Default(.crashAnalytics) var crashAnalytics
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 0) {
                    KFImage.url(URL(string: "https://ui-avatars.com/api/?name=User+Name&size=256&bold=true")!)
                        .resizable()
                        .placeholder({ progress in
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        })
                        .clipShape(Circle())
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
                Toggle(isOn: $crashAnalytics) {
                    Text("Crash Analytics")
                }
            } header: {
                Text("Misc")
            }
            
            Section {
                Toggle(isOn: $debugMode) {
                    Text("Debug")
                }
                
                if debugMode {
                    Text("SGMP \(Bundle.main.versionString ?? "NULL") (\(Bundle.main.buildString ?? "NULL"))")
                        .font(.caption.monospaced())
                    Text("User ID \(env.authUser?.userId ?? "NULL")")
                        .font(.caption.monospaced())
                    Text("Model \(UIDevice.current.model) (\(UIDevice.current.name))")
                        .font(.caption.monospaced())
                    Text("System \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                        .font(.caption.monospaced())
                }
            } header: {
                Text("Debug Info")
            }

        }.navigationTitle("Settings")
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
