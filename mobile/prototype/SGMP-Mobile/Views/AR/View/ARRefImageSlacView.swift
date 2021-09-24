//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI

struct ARRefImageSlacView: View {
    @State var showDetail = false
    @State var detailLoaded = false
    var requireLoadDetail : ((@escaping (Int) -> Void) -> ())?
    
    var body: some View {
        ZStack {
            Image("slac-template-transparent")
                .resizable()
                .scaledToFill()
                .foregroundColor(.red)
            GeometryReader { proxy in
                ZStack {
                    Color.clear
                    HStack {
                        if (!detailLoaded && showDetail)
                        {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                        } else {
                            Image(systemName: "qrcode.viewfinder")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                        }
                        if showDetail && detailLoaded {
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
                }
                .padding()
                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                .frame(width: showDetail && detailLoaded ? proxy.size.width * 0.8423 : proxy.size.height * 0.512,
                       height: showDetail && detailLoaded ? proxy.size.height * 0.646 : proxy.size.height * 0.512, alignment: .center)
                .position(x: showDetail && detailLoaded ? proxy.size.width * 0.5 : proxy.size.width * 0.81231,
                          y: showDetail && detailLoaded ? proxy.size.height * 0.516 : proxy.size.height * 0.516)
            }
        }
        .onTapGesture {
            showDetail.toggle()
            if !detailLoaded {
                requireLoadDetail?({va in })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    detailLoaded = true
                }
            }
        }
        .animation(.easeInOut(duration: 1))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARRefImageSlacView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageSlacView(requireLoadDetail: {result in })
            .frame(width: 1300/4.0, height: 500/4.0, alignment: .center)
    }
}
