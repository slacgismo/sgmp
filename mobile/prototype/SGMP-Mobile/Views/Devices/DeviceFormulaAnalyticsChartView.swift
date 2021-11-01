//
//  DeviceFormulaAnalyticsChartView.swift
//  SGMP-Mobile
//
//  Created by fincher on 11/1/21.
//

import SwiftUI
import SwiftUICharts

struct DeviceFormulaAnalyticsChartView: View {
    @State var device : DeviceDetail
    @State var formula : String
    @State var chartData : LineChartData? = nil
    @State var loading : Bool = false
    
    func refresh() {
        loading = true
        NetworkManager.shared.getAnalyticsTimeSeries(houseId: device.house_id, startDate: .now.advanced(by: -60*30), endDate: .now, forumla: formula, analyticsName: nil, interval: 3600) { frames, err in
            
            if let frames = frames {
                
                let dataPoints : [LineChartDataPoint] = frames.compactMap { frame in
                    let date = Date.init(timeIntervalSince1970: Double(frame.timestamp)/1000.0)
                    return LineChartDataPoint(value: frame.value, xAxisLabel: "\(frame.value.formatted(.number))", description: "\(date.formatted())", date: date)
                }
                let dataSets = LineDataSet.init(dataPoints: dataPoints,
                                                pointStyle: PointStyle(),
                                                style: LineStyle(lineColour: ColourStyle(colour: .init(uiColor: UIColor.secondaryLabel)), lineType: .curvedLine))
                let newChartData = LineChartData.init(dataSets: dataSets)
                DispatchQueue.main.async {
                    self.chartData = newChartData
                }
            }
            loading = false
        }
    }
    
    var body: some View {
        VStack {
            if let chartData = chartData, !loading {
                Text("Latest data: \(chartData.dataSets.dataPoints.last?.value.formatted(.number) ?? "-")")
                    .font(.footnote.monospaced().bold())
                    .foregroundColor(.init(uiColor: UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                LineChart(chartData: chartData)
            } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            if chartData == nil && !loading {
                refresh()
            }
        }
    }
}
