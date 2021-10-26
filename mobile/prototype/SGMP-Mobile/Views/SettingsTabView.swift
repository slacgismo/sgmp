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
    @Default(.userProfile) var userProfile
    @Default(.debugMode) var debugMode
    @Default(.crashAnalytics) var crashAnalytics
    
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
                    
                    Button {
                        userProfile = nil
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
            
            Section {
                Toggle(isOn: $debugMode) {
                    Text("Debug")
                }
                
                if debugMode {
                    Text("SGMP \(Bundle.main.versionString ?? "NULL") (\(Bundle.main.buildString ?? "NULL"))")
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    Text("Model \(UIDevice.current.model) (\(UIDevice.current.name))")
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    Text("System \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    Text("Token \(userProfile?.accessToken ?? "-")")
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
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
