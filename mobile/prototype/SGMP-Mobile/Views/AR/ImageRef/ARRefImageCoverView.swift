//
//  ARRefImageCoverView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/20/21.
//

import SwiftUI

struct ARRefImageCoverView: View {
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.tertiarySystemBackground).opacity(0.4)
            ZStack {
                Color(uiColor: UIColor.systemBackground).opacity(0.4).padding()
                VStack {
                    Text("SGMP UI Layer")
                    Button {
                        
                    } label: {
                        Text("Button")
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                    Slider(value: .constant(0.5), in: 0...1)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARRefImageCoverView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageCoverView()
            .frame(width: 300.0, height: 300.0)
    }
}
