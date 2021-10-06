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
            Text("AR Tracking")
            if debugMode {
                Color.clear
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
