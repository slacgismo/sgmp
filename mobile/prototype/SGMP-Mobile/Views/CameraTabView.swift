//
//  CameraTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI
import ARKit

struct CameraTabView: View {
    @State var showCameraSheet : Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        List {
            Section {
                if horizontalSizeClass == UserInterfaceSizeClass.compact {
                    Button("Open Camera") {
                        showCameraSheet.toggle()
                    }
                } else {
                    NavigationLink("Open Camera") {
                        ARGridView()
                    }
                }
            } header: {
                Text("See Grid in AR")
            }
            
            Section {
                Text("Looking for labels like this one")
                Image("slac-template")
                    .resizable()
                    .scaledToFit()
            } header: {
                Text("Guidelines")
            }
            
            
        }
        .sheet(isPresented: $showCameraSheet, onDismiss: {
            
        }, content: {
            ZStack(alignment: .topTrailing) {
                ARGridView()
                Button {
                    showCameraSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.init(uiColor: UIColor.label))
                        .padding()
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
            .interactiveDismissDisabled()
        })
        .navigationTitle("Camera")
    }
}

struct CameraTabView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTabView()
    }
}
