//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI
import Combine

struct ARRefImageSlacView: View {
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    @State var showDetail = false
    var url : String? = nil
    @State var progress = 0.5
    
    var body: some View {
        ZStack {
            Image("slac-template-transparent")
                .resizable()
                .scaledToFill()
                .foregroundColor(.red)
            ZStack {
                HStack {
//                    Button {
//                        showDetail.toggle()
//                    } label: {
////                        Image(systemName: "qrcode.viewfinder")
////                            .renderingMode(.template)
////                            .resizable()
////                            .scaledToFit()
////                            .foregroundColor(.white)
//                        Text("🤔")
//                    }
//                    .buttonStyle(BorderedButtonStyle())

                    Image(systemName: "qrcode.viewfinder")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
//                    Toggle(isOn: $showDetail) {
//
//                    }
                    
                    if showDetail{
                        Text("\(url ?? "")")
                            .font(.headline.monospaced())
                            .foregroundColor(.white)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8).foregroundColor(.red)
                }
            }
            .frame(width: showDetail ? ARRefImageSlacView.preferredSize.width * 0.8423 : ARRefImageSlacView.preferredSize.height  * 0.512,
                   height: showDetail ? ARRefImageSlacView.preferredSize.height  * 0.646 : ARRefImageSlacView.preferredSize.height  * 0.512, alignment: .center)
            .position(x: showDetail ? ARRefImageSlacView.preferredSize.width * 0.5 : ARRefImageSlacView.preferredSize.width * 0.81231,
                      y: showDetail ? ARRefImageSlacView.preferredSize.height  * 0.516 : ARRefImageSlacView.preferredSize.height  * 0.516)
            
            .contentShape(Rectangle())
            .onTapGesture {
                showDetail.toggle()
            }
        }
        .animation(.easeInOut(duration: 1))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARRefImageSlacView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageSlacView()
            .frame(width: ARRefImageSlacView.preferredSize.width, height: ARRefImageSlacView.preferredSize.height , alignment: .center)
    }
}
