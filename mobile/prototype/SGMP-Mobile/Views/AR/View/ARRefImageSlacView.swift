//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI

struct ARRefImageSlacView: View {
    @State var showDetail = false
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    var requireLoadDetail : ((@escaping (Int) -> Void) -> ())?
    
    var body: some View {
        ZStack {
            Image("slac-template-transparent")
                .resizable()
                .scaledToFill()
                .foregroundColor(.red)
            ZStack {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                    if showDetail{
                        VStack(alignment: .leading, spacing: 2) {
                            Text("QR Parsed")
                                .font(.headline.smallCaps())
                                .foregroundColor(.white)
                            Text("Result")
                                .font(.headline.smallCaps())
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                requireLoadDetail?({va in })
            }
        }
        .animation(.easeInOut(duration: 1))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARRefImageSlacView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageSlacView(requireLoadDetail: {result in })
            .frame(width: ARRefImageSlacView.preferredSize.width, height: ARRefImageSlacView.preferredSize.height , alignment: .center)
            .environmentObject(EnvironmentManager.shared.env)
    }
}
