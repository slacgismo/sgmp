//
//  ARRefImageCoverView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/20/21.
//

import SwiftUI

struct ARRefImageCoverView: View {
    @State var clicked = false
    @State var toggled = false
    @State var slider = 0.5
    @State var input = ""
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.tertiarySystemBackground).opacity(0.8)
            ZStack {
                Color(uiColor: UIColor.systemBackground).opacity(0.8).padding()
                VStack {
                    Text("SGMP UI Layer")
                    Button {
                        DispatchQueue.main.async {
                            clicked.toggle()
                        }
                    } label: {
                        Text("Button \(clicked ? "1" : "0")")
                    }
                    .padding()
                    
                    Toggle(isOn: $toggled) {
                        Text("Toggle")
                    }
                    
                    TextField("Input", text: $input)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()

                    Slider(value: $slider, in: 0...1)
                        .padding()
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
