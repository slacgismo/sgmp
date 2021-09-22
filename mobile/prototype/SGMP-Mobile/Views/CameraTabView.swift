//
//  CameraTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI

struct CameraTabView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Open Camera") {
                    ARGridViewControllerRepresentable()
                        .ignoresSafeArea()
                }
            } header: {
                Text("See Grid in AR")
            }
            
            Section {
                Text("Looking for QR code")
            } header: {
                Text("Guidelines")
            }
            
            
        }.navigationTitle("Camera")
    }
}

struct CameraTabView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTabView()
    }
}
