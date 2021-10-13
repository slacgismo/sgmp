//
//  ARRefImageSlacView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/23/21.
//

import SwiftUI
import Combine
import SwiftUICharts

struct ARRefImageSlacView: View {
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    @State var showDetail = false
    var url : String? = nil
    var chartData : [Double]
    {
        if let url = url {
            if url == "1" {
                return [12, 2, 7, 6, 10, 3, 10]
            } else if url == "2" {
                return [0, 1, 2, 3, 10, 3, 5]
            }
        }
        return [0, 0, 0, 0, 0, 3, 5]
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                    
                    if showDetail{
                        Text("Device \(url ?? "")")
                            .font(.caption.monospaced().bold())
                            .foregroundColor(.white)
                            .lineLimit(nil)
                        Spacer()
                        Text("\(chartData.last ?? 0) %")
                            .font(.caption.monospaced().bold())
                            .foregroundColor(.white)
                            .lineLimit(nil)
                    }
                }
                
                if showDetail {
                    LineChart()
                            .data(chartData)
                            .chartStyle(ChartStyle(backgroundColor: .red,
                                                               foregroundColor: [ColorGradient(.white, .white)]))
                            .layoutPriority(100)
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
        .onTapGesture {
            showDetail.toggle()
        }
    }
}

struct ARRefImageSlacView_Previews: PreviewProvider {
    static var previews: some View {
        ARRefImageSlacView(url: "1")
            .frame(width: ARRefImageSlacView.preferredSize.width, height: ARRefImageSlacView.preferredSize.height , alignment: .center)
            .background(.yellow)
    }
}
