//
//  ARDebugView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI
import Defaults

struct ARDebugPanelView: View {
    @EnvironmentObject var env : Env
    
    var body: some View {
        VStack {
            Text("Debug")
                .font(.caption.smallCaps())
//            HStack(alignment: .top) {
//                if let debugInfo : ARTrackingObjectDataModel = env.arTrackingObject, let image = debugInfo.croppedImage{
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: debugInfo.decodeString.isEmpty ? "xmark" : "checkmark")
//                            Text("Parsed QR")
//                                .font(.body.bold())
//                        }
//                        Text(debugInfo.decodeString)
//                            .font(.caption.monospaced())
//                    }
//                }
//            }
        }
        .padding()
    }
}
