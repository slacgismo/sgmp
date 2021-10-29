//
//  ARGridView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI
import Defaults

struct ARGridView: View {
    @EnvironmentObject var env : Env
    @Default(.debugMode) var debugMode
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                ARGridViewControllerRepresentable()
                    .ignoresSafeArea()
                ZStack {
                    if debugMode {
                        ARDebugPanelView()
                    } else {
                        ARDeviceInfoPanelView()
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: proxy.size.width * 1.0, maxHeight: proxy.size.height * 0.55, alignment: .bottom)
            }
            .animation(.easeInOut)
        }
    }
}

struct ARGridView_Previews: PreviewProvider {
    static var previews: some View {
        ARGridView()
    }
}
