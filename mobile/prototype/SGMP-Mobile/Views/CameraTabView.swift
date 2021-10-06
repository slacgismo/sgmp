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
    var body: some View {
        List {
            Section {
                Button("Open Camera") {
                    showCameraSheet.toggle()
                }
//                NavigationLink("Open Camera") {
//                    VStack {
//                        ARGridViewControllerRepresentable()
//                        ARDebugView()
//                    }
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationTitle("AR Grid")
//                }
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
        })
        .navigationTitle("Camera")
    }
}

struct CameraTabView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTabView()
    }
}
