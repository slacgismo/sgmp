//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI

struct ARRefImageSlacView: View {
    @State var showDetail = false
    let width : CGFloat
    let height : CGFloat
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
            .frame(width: showDetail ? width * 0.8423 : height * 0.512,
                   height: showDetail ? height * 0.646 : height * 0.512, alignment: .center)
            .position(x: showDetail ? width * 0.5 : width * 0.81231,
                      y: showDetail ? height * 0.516 : height * 0.516)
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
        ARRefImageSlacView(width: 1300.0/4.0, height: 500.0/4.0, requireLoadDetail: {result in })
            .frame(width: 1300/4.0, height: 500/4.0, alignment: .center)
            .environmentObject(EnvironmentManager.shared.env)
    }
}
