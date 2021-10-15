//
//  SpecificDeviceKeyChartSelfLoadView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI
import SwiftUICharts

struct SpecificDeviceKeyChartSelfLoadView: View {
    var device : Device
    var key : String
    @State var date : (Date, Date)
    @State var frames : [DeviceKeyAnalyticsFrame]?
    @State var loadingChart : Bool = false
    
    func loadChart() {
        loadingChart = true
        DeviceManager.shared.getDeviceKeyAnalytics(device: device, key: key, startDate: date.0, endDate: date.1) { frames, err in
            if let frames = frames {
                self.frames = frames
            } else if let err = err {
                print(err)
            }
            self.loadingChart = false
        }
    }
    
    var body: some View {
        ZStack {
            if loadingChart {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let frames = frames  {
                LineChart()
                    .data(frames.map {frame in frame.value})
                    .chartStyle(ChartStyle(backgroundColor: .clear, foregroundColor: [ColorGradient(.init(uiColor: UIColor.label), .init(uiColor: UIColor.label))]))
            } else {
                Button("Load Chart") {
                    loadChart()
                }
            }
        }
        .onAppear(perform: {
            loadChart()
        })
    }
}

struct SpecificDeviceKeyChartSelfLoadView_Previews: PreviewProvider {
    static var previews: some View {
//        SpecificDeviceKeyChartSelfLoadView()
        ZStack {}
    }
}
