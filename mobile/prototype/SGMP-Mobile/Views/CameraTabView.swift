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
                NavigationLink("CoreML / Vision") {
                    
                }
                
                NavigationLink("ARKit (Object)") {
                    
                }
                
                NavigationLink("ARKit (Image)") {
                    ARRefImageViewRepresentable()
                        .ignoresSafeArea()
                }
            } header: {
                Text("AR Modes")
            }
            
            
        }.navigationTitle("Camera")
    }
}

struct CameraTabView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTabView()
    }
}
