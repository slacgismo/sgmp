//
//  SettingsTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import Defaults
import SwiftUI
import Kingfisher


/**
 Tab view for settings 
 */
struct SettingsTabView: View {
    @EnvironmentObject var env : Env
    @Default(.userProfile) var userProfile
    @Default(.debugMode) var debugMode
    @Default(.crashAnalytics) var crashAnalytics
    @Default(.customEndpoint) var customEndpoint
    @Default(.customEndpointUrl) var customEndpointUrl
    
    var body: some View {
        List {
            if let user = userProfile {
                Section {
                    HStack(alignment: .center) {
                        KFImage.url(URL(string: "https://ui-avatars.com/api/?name=\(user.name.replacingOccurrences(of: " ", with: "+"))&size=256&bold=true&background=random")!)
                            .resizable()
                            .placeholder({ progress in
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            })
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                            .frame(idealWidth: 64, idealHeight: 64)
                            .layoutPriority(0.1)
                        
                        VStack(alignment: .leading) {
                            Text("\(user.name)")
                                .font(.title.bold())
                            Text("\(user.email)")
                                .font(.footnote)
                                .foregroundColor(.init(UIColor.secondaryLabel))
                            Text("\(user.roles.joined(separator: ", "))")
                                .font(.caption.smallCaps().bold())
                                .foregroundColor(.init(UIColor.quaternaryLabel))
                        }
                        .layoutPriority(0.9)
                    }
                    .padding(.vertical)
                    
                    if debugMode {
                        Button {
                            SessionManager.shared.refreshToken()
                        } label: {
                            Text("Refresh Token")
                        }
                    }
                    
                    Button {
                        SessionManager.shared.logout()
                    } label: {
                        Text("Logout")
                    }
                } header: {
                    Text("User")
                }
            }
            
            Section {
                NavigationLink("About", destination: AboutAppView())
                Toggle(isOn: $crashAnalytics) {
                    Text("Crash Analytics")
                }
            } header: {
                Text("Misc")
            }
            
            #if DEBUG
            Section {
                Toggle(isOn: $debugMode) {
                    Text("Debug")
                }
                
                if debugMode {
                    NavigationLink("Debug Variables", destination: EnvVariableView())
                    
                    Toggle(isOn: $customEndpoint) {
                        Text("Custom API Endpoint")
                    }
                    
                    if customEndpoint {
                        TextField("Endpoint", text: $customEndpointUrl, prompt: Text("http://").font(.body.monospaced()))
                            .textFieldStyle(DefaultTextFieldStyle())
                            .font(.body.monospaced())
                    }
                }
            } header: {
                Text("Extras")
            }
            #endif
        }
        .animation(.easeInOut)
        .navigationTitle("Settings")
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
