//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI
import Combine
import SwiftUICharts

struct ARRefImageSlacInternalView : View {
    init() {
        showDetail = false
    }
    
    @EnvironmentObject var env : Env
    @State var showDetail = false
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "qrcode.viewfinder")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                
                if showDetail{
                    VStack(alignment: .leading) {
                        Text("\(env.arTrackingDevice?.name ?? "")")
                            .font(.title.monospaced())
                            .foregroundColor(.white)
                            .lineLimit(nil)
                        Text("\(env.arTrackingDevice?.description ?? "")")
                            .font(.footnote.monospaced().bold())
                            .foregroundColor(.white)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                }
            }
            .padding(.all, showDetail ? 8 : 12)
            .background {
                RoundedRectangle(cornerRadius: 8).foregroundColor(.red)
            }
            .frame(width: showDetail ? ARRefImageSlacView.preferredSize.width * 0.8423 : ARRefImageSlacView.preferredSize.height  * 0.512,
                   height: showDetail ? ARRefImageSlacView.preferredSize.height  * 0.646 : ARRefImageSlacView.preferredSize.height  * 0.512, alignment: .center)
            .position(x: showDetail ? ARRefImageSlacView.preferredSize.width * 0.5 : ARRefImageSlacView.preferredSize.width * 0.81231,
                      y: showDetail ? ARRefImageSlacView.preferredSize.height  * 0.516 : ARRefImageSlacView.preferredSize.height  * 0.516)
            
            Image("slac-template-transparent")
                .resizable()
                .scaledToFill()
                .foregroundColor(.red)
                .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: 1))
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .contentShape(Rectangle())
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showDetail = true
            }
        })
        .onTapGesture {
            showDetail.toggle()
        }
    }
    
}

struct ARRefImageSlacView: View {
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    
    var body: some View {
        ARRefImageSlacInternalView()
            .environmentObject(EnvironmentManager.shared.env)
    }
}

struct ARRefImageSlacView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageSlacView()
            .frame(width: ARRefImageSlacView.preferredSize.width, height: ARRefImageSlacView.preferredSize.height , alignment: .center)
            .background(.yellow)
    }
}
