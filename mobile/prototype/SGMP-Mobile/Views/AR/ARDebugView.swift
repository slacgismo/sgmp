//
//  ARDebugView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI
import Defaults

struct ARDebugView: View {
    @EnvironmentObject var env : Env
    @Default(.debugMode) var debugMode
    
    var body: some View {
        VStack {
            if debugMode {
                Color.clear
            } else {
                Text("AR Tracking \(env.arCameraTrackingState.desc)")
                    .font(.caption.smallCaps())
            }
        }
        .padding()
    }
}

struct ARDebugView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugView()
    }
}
