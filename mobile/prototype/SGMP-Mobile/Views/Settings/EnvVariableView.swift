//
//  EnvVariableView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/31/21.
//

import SwiftUI
import Defaults


/**
 Debug view for `Env` variables
 */
struct EnvVariableView: View {
    
    /// User Profile (`UserProfile`) that syncs with `Defaults.Keys.userProfile`
    @Default(.userProfile) var userProfile
    
    var body: some View {
        List {
            Text("SGMP \(Bundle.main.versionString ?? "NULL") (\(Bundle.main.buildString ?? "NULL"))")
                .font(.caption.monospaced())
                .textSelection(.enabled)
            Text("Model \(UIDevice.current.model) (\(UIDevice.current.name))")
                .font(.caption.monospaced())
                .textSelection(.enabled)
            Text("System \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                .font(.caption.monospaced())
                .textSelection(.enabled)
            Text("Access Token \(userProfile?.accessToken ?? "-")")
                .font(.caption.monospaced())
                .textSelection(.enabled)
            Text("Access Token Updated \(userProfile?.accessTokenUpdatedDate.formatted() ?? "-")")
                .font(.caption.monospaced())
                .textSelection(.enabled)
            Text("Refresh Token \(userProfile?.refreshToken ?? "-")")
                .font(.caption.monospaced())
                .textSelection(.enabled)
        }.navigationTitle("Debug Variables")
    }
}
