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
                ZStack {
                    VStack {
                        Text("Debug")
                            .font(.caption.smallCaps())
                        HStack(alignment: .top) {
                            if let debugInfo : ARDebugDataModel = env.arDebugInfo {
                                Image(uiImage: debugInfo.croppedImage)
                                    .resizable()
                                    .scaledToFit()
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: debugInfo.decodeString.isEmpty ? "xmark" : "checkmark")
                                        Text("Parsed QR")
                                            .font(.body.bold())
                                    }
                                    Text(debugInfo.decodeString)
                                        .font(.caption.monospaced())
                                }
                            }
                        }
                    }
                }
            } else {
                ZStack {
                    VStack {
                        Text("Control Panel")
                            .font(.caption.smallCaps())
                        VStack(alignment: .leading) {
                            if let debugInfo : ARDebugDataModel = env.arDebugInfo {
                                Text(debugInfo.decodeString)
                                    .font(.caption.monospaced())
                            }
                        }
                    }
                }
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
